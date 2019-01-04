# frozen_string_literal: true

class TransportCategory < ApplicationRecord
  LOAD_TYPE_CARGO_CLASSES = {
    'container' => %w(
      fcl_20
      fcl_40
      fcl_40_hq
    ),
    'cargo_item' => %w(
      lcl
    )
  }.freeze
  LOAD_TYPES = LOAD_TYPE_CARGO_CLASSES.keys

  belongs_to :vehicle

  before_validation :set_load_type

  validates :cargo_class, presence: true

  LOAD_TYPES.each do |load_type|
    validates :cargo_class,
              inclusion: {
                in: LOAD_TYPE_CARGO_CLASSES[load_type],
                message: "must be included in #{LOAD_TYPE_CARGO_CLASSES[load_type].log_format}"
              },
              if: -> { self.load_type == load_type }

    # This allows the following example usage for every load type:
    # TransportCategory.container_load_type #=> collection of TransportCategory instances
    scope "#{load_type}_load_type".to_sym, -> { where(load_type: load_type) }
  end

  # This allows the following example usage:
  # TransportCategory.load_type("container") #=> collection of TransportCategory instances
  scope :load_type,   ->(load_type)   { where(load_type: load_type) }
  scope :cargo_class, ->(cargo_class) { where(cargo_class: cargo_class) }

  validates :load_type,
            presence: true,
            inclusion: {
              in: LOAD_TYPES,
              message: "must be included in #{LOAD_TYPES.log_format}"
            }

  validates :name,
            presence: true,
            uniqueness: {
              scope: %i(vehicle_id cargo_class),
              message: lambda do |_self, _|
                         "'#{_self.name}' taken for " \
                             "vehicle id '#{_self.vehicle_id}' cargo class '#{_self.cargo_class}'"
                       end
            }

  def humanize
    "#{humanized_cargo_class} #{humanized_name} #{humanized_load_type}"
  end

  def humanized_cargo_class
    cargo_class.split('_')
               .map.with_index { |str_elem, _i| str_elem.upcase }
               .join(' – ')
               .gsub(/(?<=(20|40))F/, '’')
  end

  def humanized_name
    name.tr('_', ' ').gsub(/( any| goods)/, '')
  end

  def humanized_load_type
    load_type.tr('_', ' ')
  end

  private

  def set_load_type
    LOAD_TYPES.each do |_load_type|
      self.load_type = _load_type if cargo_class_is_from?(_load_type)
    end
  end

  def cargo_class_is_from?(load_type)
    LOAD_TYPE_CARGO_CLASSES[load_type].include?(cargo_class)
  end
end
