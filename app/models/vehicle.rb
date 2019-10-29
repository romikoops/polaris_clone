# frozen_string_literal: true

class Vehicle < Legacy::Vehicle
  has_many :transport_categories
  has_many :itineraries
  has_many :tenant_vehicles

  validates :name,
            presence: true,
            uniqueness: {
              scope: %i(mode_of_transport),
              message: ->(obj, _) { "'#{obj.name}' taken for mode of transport '#{obj.mode_of_transport}'" }
            }

  def create_all_transport_categories
    [true, false].each do |sandbox|
      CARGO_CLASSES.each do |cargo_class|
        TRANSPORT_CATEGORY_NAMES.each do |transport_category_name|
          transport_category = TransportCategory.new(
            name: transport_category_name,
            mode_of_transport: mode_of_transport,
            cargo_class: cargo_class,
            vehicle: self,
            sandbox: sandbox
          )
          puts transport_category.errors.full_messages unless transport_category.save
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: vehicles
#
#  id                :bigint           not null, primary key
#  name              :string
#  mode_of_transport :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
