# frozen_string_literal: true

FactoryBot.define do
  factory :map_datum do
  end
end

# == Schema Information
#
# Table name: map_data
#
#  id           :bigint(8)        not null, primary key
#  line         :jsonb
#  geo_json     :jsonb
#  origin       :decimal(, )      default([]), is an Array
#  destination  :decimal(, )      default([]), is an Array
#  itinerary_id :string
#  tenant_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sandbox_id   :uuid
#
