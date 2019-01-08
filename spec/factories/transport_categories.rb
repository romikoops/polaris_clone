# frozen_string_literal: true


FactoryBot.define do
  factory :transport_category do
    name 'any'
    mode_of_transport 'ocean'
    cargo_class 'fcl_20'
    load_type 'container'
    before(:create) do |transport_category|
      transport_category.update(
        vehicle: Vehicle.where(mode_of_transport: "ocean").first || create(:vehicle)
      )
    end
  end

end

# == Schema Information
#
# Table name: transport_categories
#
#  id                :bigint(8)        not null, primary key
#  vehicle_id        :integer
#  mode_of_transport :string
#  name              :string
#  cargo_class       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  load_type         :string
#
