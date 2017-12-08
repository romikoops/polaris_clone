class HubRoute < ApplicationRecord
  has_many :schedules
  belongs_to :starthub, class_name: "Hub"
  belongs_to :endhub, class_name: "Hub"
  def self.create_from_route(route, mot)
    o_hubs = route.origin_nexus.hubs_by_type(mot)
    d_hubs = route.destination_nexus.hubs_by_type(mot)
    return route.hub_routes.find_or_create_by(starthub_id: o_hubs[0].id, endhub_id: d_hubs[0].id)
  end

  def generate_weekly_schedules(mot, start_date, end_date, ordinal_array, journey_length, vehicle_type_id)
    tmp_date = start_date
    sched_key = "#{self.starthub.id}-#{self.endhub.id}"
    while tmp_date < end_date
      if ordinal_array.include?(tmp_date.strftime("%u").to_i)
        etd = tmp_date.midday
        eta = etd + journey_length.days
        new_sched = {mode_of_transport: mot, eta: eta, etd: etd, vehicle_type_id: vehicle_type_id, hub_route_key: sched_key}
         # byebug
        self.schedules.find_or_create_by!(new_sched)
        
      end
      tmp_date += 1.day
    end
  end

  def generate_weekly_schedules_from_hubs(starthub, endhub, mot, start_date, end_date, ordinal_array, journey_length, vehicle_type_id)
    tmp_date = start_date
    while tmp_date < end_date
      if ordinal_array.include?(tmp_date.strftime("%u").to_i)
        etd = tmp_date.midday
        eta = etd + journey_length.days
        new_sched = {starthub_id: starthub, endhub_id: endhub, eta: eta, etd: etd, vehicle_type_id: vehicle_type_id}
         # byebug
        self.schedules.find_or_create_by(new_sched)
        
      end
      tmp_date += 1.day
    end
  end
end
