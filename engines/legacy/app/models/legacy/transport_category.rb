# frozen_string_literal: true

module Legacy
  class TransportCategory < ApplicationRecord
    self.table_name = 'transport_categories'
    LOAD_TYPE_CARGO_CLASSES = {
      'container' => Container::CARGO_CLASSES,
      'cargo_item' => %w(
        lcl
      )
    }.freeze
    LOAD_TYPES = LOAD_TYPE_CARGO_CLASSES.keys.freeze

    belongs_to :vehicle
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    validates :cargo_class, presence: true
    LOAD_TYPES.each do |load_type|
      validates :cargo_class,
                inclusion: {
                  in: LOAD_TYPE_CARGO_CLASSES[load_type],
                  message: "must be included in #{LOAD_TYPE_CARGO_CLASSES[load_type]}"
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
                message: "must be included in #{LOAD_TYPES}"
              }

    validates :name,
              presence: true,
              uniqueness: { scope: %i(vehicle_id cargo_class) }

    before_validation :set_load_type

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
      LOAD_TYPES.each do |ld|
        self.load_type = ld if cargo_class_is_from?(ld)
      end
    end

    def cargo_class_is_from?(load_type)
      LOAD_TYPE_CARGO_CLASSES[load_type].include?(cargo_class)
    end
  end
end

# == Schema Information
#
# Table name: transport_categories
#
#  id                :bigint           not null, primary key
#  vehicle_id        :integer
#  mode_of_transport :string
#  name              :string
#  cargo_class       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  load_type         :string
#  sandbox_id        :uuid
#
