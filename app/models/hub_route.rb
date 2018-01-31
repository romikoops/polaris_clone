class HubRoute < ApplicationRecord
  has_many :schedules
  belongs_to :route
  has_many :vehicles, through: :schedules
  belongs_to :starthub, class_name: "Hub"
  belongs_to :endhub, class_name: "Hub"

  def self.create_from_route(route, mot, tenant_id)
    o_hubs = route.origin_nexus.hubs_by_type(mot, tenant_id)
    if o_hubs.empty?
      o_hubs = [Hub.create_from_nexus(route.origin_nexus, mot, tenant_id)]
    end
    d_hubs = route.destination_nexus.hubs_by_type(mot, tenant_id)
    if d_hubs.empty?
      d_hubs = [Hub.create_from_nexus(route.destination_nexus, mot, tenant_id)]
    end

    p d_hubs[0].tenant_id
    p o_hubs[0].tenant_id
    newname = "#{o_hubs[0].name} - #{d_hubs[0].name}"
    
    return route.hub_routes.find_or_create_by(starthub_id: o_hubs[0].id, endhub_id: d_hubs[0].id, name: newname)
  end

  def self.create_with_route(starthub_id, endhub_id, mot, tenant_id)
    o_hub = Hub.find(starthub_id)
    d_hub = Hub.find(endhub_id)
    o_nexus = o_hub.nexus
    d_nexus = d_hub.nexus
    route_name = "#{o_nexus.name} - #{d_nexus.name}"
    hub_route_name = "#{o_hub.name} - #{d_hub.name}"
    route = Route.find_or_create_by!(origin_nexus_id: o_nexus.id, destination_nexus_id: d_nexus.id, tenant_id: tenant_id, name: route_name)
    hub_route = route.hub_routes.create!(starthub_id: starthub_id, endhub_id: endhub_id, name: hub_route_name)
    return hub_route
  end

  def generate_weekly_schedules(mot, start_date, end_date, ordinal_array, journey_length, vehicle_type_id)
    if start_date.kind_of? Date
      tmp_date = start_date
    else
      tmp_date = DateTime.parse(start_date)
    end
    if end_date.kind_of? Date
      end_date_parsed = end_date
    else
      end_date_parsed = DateTime.parse(end_date)
    end
    end_date = tmp_date + 3.months
    tenant_id = self.route.tenant_id
    sched_key = "#{self.starthub.id}-#{self.endhub.id}"

    
    while tmp_date < end_date_parsed
      if ordinal_array.include?(tmp_date.strftime("%u").to_i)
        etd = tmp_date.midday
        eta = etd + journey_length.days
        new_sched = {mode_of_transport: mot, eta: eta, etd: etd, vehicle_id: vehicle_type_id, hub_route_key: sched_key, tenant_id: tenant_id}

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
        new_sched = {starthub_id: starthub, endhub_id: endhub, eta: eta, etd: etd, vehicle_id: vehicle_type_id}
         # 
        self.schedules.find_or_create_by(new_sched)
        
      end
      tmp_date += 1.day
    end
  end

  def self.fix_hubs
    hrs = HubRoute.all
    hrs.each do |hr|
      p "HUBROUTE #{hr.id}"
      route = hr.route
      o_hub = hr.starthub
      d_hub = hr.endhub
      mot = hr.schedules.first.mode_of_transport
      if o_hub.tenant_id != route.tenant_id
        p route.tenant_id
        p o_hub.tenant_id
        o_hubs = route.origin_nexus.hubs_by_type(mot, route.tenant_id)
        if o_hubs[0]
          hr.starthub = o_hubs[0]
        else
          new_hub = o_hub.as_json
          new_hub["tenant_id"] = route.tenant_id
          new_hub.delete("id")
          hr.starthub = Hub.create!(new_hub)
        end
        
      end
      if d_hub.tenant_id != route.tenant_id
        p route.tenant_id
        p d_hub.tenant_id
        d_hubs = route.destination_nexus.hubs_by_type(mot, route.tenant_id)
        if d_hubs[0]
          hr.endhub = d_hubs[0]
        else
          new_hub = d_hub.as_json
          new_hub["tenant_id"] = route.tenant_id
          new_hub.delete("id")
          hr.endhub = Hub.create!(new_hub)
        end
      end
      hr.save!
    end
  end

  def update_name
    starthub = self.starthub
    endhub = self.endhub
    newname = "#{starthub.name} - #{endhub.name}"
    self.name = newname
    self.save!
  end

  def self.update_all_names
   all_hub_routes = HubRoute.all
   all_hub_routes.each do |hr|
      hr.update_name
   end
  end
end
