class MapDatum < ApplicationRecord
  belongs_to :itinerary
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
