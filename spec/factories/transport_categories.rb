# frozen_string_literal: true

FactoryBot.define do
  factory :transport_category do
    name { 'any' }
    mode_of_transport { 'ocean' }
    cargo_class { 'fcl_20' }
    load_type { 'container' }
    before(:create) do |transport_category|
      transport_category.update(
        vehicle: Vehicle.where(mode_of_transport: 'ocean').first || create(:vehicle)
      )
    end
  end
end

# == Schema Information
#
# Table name: transport_categories
#
#  id                :bigint           not null, primary key
#  cargo_class       :string
#  load_type         :string
#  mode_of_transport :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#  vehicle_id        :integer
#
# Indexes
#
#  index_transport_categories_on_sandbox_id  (sandbox_id)
#
