# frozen_string_literal: true

class MapDatum < ApplicationRecord
  belongs_to :itinerary
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
  belongs_to :tenant

  def self.create_all_from_itineraries
    Itinerary.all.each do |itinerary|
      routes_data = itinerary.routes
      routes_data.each do |route_data|
        route_data[:tenant_id] = itinerary.tenant_id
        itinerary.map_data.find_or_create_by!(route_data)
      end
    end
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
