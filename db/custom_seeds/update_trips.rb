Itinerary.find_in_batches do |itineraries|
  itineraries.each do |itinerary|
    tenant_vehicle_ids = itinerary.pricings.pluck(:tenant_vehicle_id)
    tenant_vehicle_ids.each do |tenant_vehicle_id|
      load_types = ActiveRecord::Base.connection.execute("SELECT DISTINCT transport_categories.load_type FROM \"pricings\" INNER JOIN \"transport_categories\" ON \"transport_categories\".\"id\" = \"pricings\".\"transport_category_id\" WHERE \"pricings\".\"itinerary_id\" = #{itinerary.id} AND \"pricings\".\"tenant_vehicle_id\" = #{tenant_vehicle_id} ORDER BY \"transport_categories\".\"load_type\"").values.flatten
      
      if load_types.empty?
        next
      end
      if load_types.length == 1
        itinerary.trips.where(tenant_vehicle_id: tenant_vehicle_id, load_type: nil).update_all(load_type: load_types.first)
      else
        itinerary.trips.where(load_type: nil).find_each do |trip|
          new_trip = trip.dup()
          trip.update!(load_type: load_types.first)
          new_trip.load_type = load_types.second
          if new_trip.save!
            trip.layovers.find_each do |layover|
              new_layover = layover.dup()
              new_layover.trip_id = new_trip.id
              new_layover.save!
            end
          end
        end
      end
    end
  end
end