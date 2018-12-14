genObj = {
  normanglobal: {
    container: [
      {origin: 'DALIAN', destination:	'FELIXSTOWE', departure:	'THURSDAY', transit_time:	38},
      {origin: 'DALIAN', destination:	'SOUTHAMPTON', departure:	'WEDNESDAY', transit_time:	34},
      {origin: 'XINGANG', destination:	'FELIXSTOWE', departure:	'SATURDAY', transit_time:	40},
      {origin: 'XINGANG', destination:	'SOUTHAMPTON', departure:	'SATURDAY', transit_time:	36},
      {origin: 'TIANJIN', destination:	'FELIXSTOWE', departure:	'SATURDAY', transit_time:	40},
      {origin: 'TIANJIN', destination:	'SOUTHAMPTON', departure:	'SATURDAY', transit_time:	36},
      {origin: 'QINGDAO', destination:	'FELIXSTOWE', departure:	'THURSDAY', transit_time:	34},
      {origin: 'QINGDAO', destination:	'SOUTHAMPTON', departure:	'MONDAY', transit_time:	34},
      {origin: 'SHANGHAI', destination:	'FELIXSTOWE', departure:	'MONDAY', transit_time:	30},
      {origin: 'SHANGHAI', destination:	'SOUTHAMPTON', departure:	'SUNDAY', transit_time:	28},
      {origin: 'SHANGHAI', destination:	'FELIXSTOWE', departure:	'THURSDAY', transit_time:	31},
      {origin: 'NINGBO', destination:	'FELIXSTOWE', departure:	'WEDNESDAY', transit_time:	29},
      {origin: 'NINGBO', destination:	'SOUTHAMPTON', departure:	'FRIDAY', transit_time:	30},
      {origin: 'XIAMEN', destination:	'FELIXSTOWE', departure:	'FRIDAY', transit_time:	26},
      {origin: 'XIAMEN', destination:	'SOUTHAMPTON', departure:	'FRIDAY', transit_time:	30},
      {origin: 'HONG KONG', destination:	'FELIXSTOWE', departure:	'SUNDAY', transit_time:	27},
      {origin: 'HONG KONG', destination:	'SOUTHAMPTON', departure:	'MONDAY', transit_time:	27},
      {origin: 'SHENZHEN', destination:	'FELIXSTOWE', departure:	'FRIDAY', transit_time:	27},
      {origin: 'SHENZHEN', destination:	'SOUTHAMPTON', departure:	'MONDAY', transit_time:	27}
    ],
    cargo_item: [
      {origin: 'DALIAN', destination: 'SOUTHAMPTON'	, departure:'THURSDAY',	transit_time: 35},
      {origin: 'XINGANG', destination: 'FELIXSTOWE'	, departure:'MONDAY',	transit_time: 40},
      {origin: 'XINGANG', destination: 'SOUTHAMPTON'	, departure:'FRIDAY',	transit_time: 40},
      {origin: 'TIANJIN', destination: 'FELIXSTOWE'	, departure:'MONDAY',	transit_time: 40},
      {origin: 'TIANJIN', destination: 'SOUTHAMPTON'	, departure:'FRIDAY',	transit_time: 40},
      {origin: 'QINGDAO', destination: 'FELIXSTOWE'	, departure:'SATURDAY',	transit_time: 38},
      {origin: 'QINGDAO', destination: 'SOUTHAMPTON'	, departure:'SATURDAY',	transit_time: 38},
      {origin: 'SHANGHAI', destination: 'FELIXSTOWE'	, departure:'SUNDAY',	transit_time: 30},
      {origin: 'SHANGHAI', destination: 'SOUTHAMPTON'	, departure:'SUNDAY',	transit_time: 30},
      {origin: 'NINGBO', destination: 'FELIXSTOWE'	, departure:'WEDNESDAY',	transit_time: 27},
      {origin: 'NINGBO', destination: 'SOUTHAMPTON'	, departure:'FRIDAY',	transit_time: 27},
      {origin: 'XIAMEN', destination: 'FELIXSTOWE'	, departure:'SATURDAY',	transit_time: 25},
      {origin: 'XIAMEN', destination: 'SOUTHAMPTON'	, departure:'SATURDAY',	transit_time: 23},
      {origin: 'HONG KONG', destination: 'FELIXSTOWE'	, departure:'SUNDAY',	transit_time: 27},
      {origin: 'HONG KONG', destination: 'SOUTHAMPTON'	, departure:'FRIDAY',	transit_time: 27},
      {origin: 'SHENZHEN', destination: 'FELIXSTOWE'	, departure:'MONDAY',	transit_time: 24},
      {origin: 'SHENZHEN', destination: 'SOUTHAMPTON'	, departure:'WEDNESDAY',	transit_time: 24}
    ]
  }
}

ordinalLookup = {
  "MONDAY": 1,
  "TUESDAY": 2,
  "WEDNESDAY": 3,
  "THURSDAY": 4,
  "FRIDAY": 5,
  "SATURDAY": 6,
  "SUNDAY": 0

}
genObj.each do |subdomain, cargo_class_routes|
  cargo_class_routes.each do |cargo_class, routes|
    tenant = Tenant.find_by_subdomain(subdomain)
    routes.each do |genData|
      itinerary = Itinerary.find_by(tenant_id: tenant.id, name: "#{genData[:origin].titleize} - #{genData[:destination].titleize}")
      next if !itinerary
      tenant_vehicle_ids = itinerary.pricings.for_load_type(cargo_class.to_s).pluck(:tenant_vehicle_id).uniq
      stops_in_order = itinerary.stops.order(:index)
      today = Date.today
      finish_date = today + 6.months
      p itinerary.name
      tenant_vehicle_ids.each do |tv_id|
        itinerary.generate_weekly_schedules(
          stops_in_order,
          [genData[:transit_time]],
          DateTime.now,
          finish_date,
          [ordinalLookup[genData[:departure].to_sym]],
          tv_id,
          4
        )
      end
    end
  end
end
