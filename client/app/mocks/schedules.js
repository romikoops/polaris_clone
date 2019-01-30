const base = {
  hub_route_key: 'HUB_ROUTE_KEY',
  total_price: { currency: 'EUR', value: 112 },
  origin_hub: {},
  destination_hub: {},
  eta: '2018-11-22T11:14:33z',
  etd: '2018-11-17T11:14:33z',
  closing_date: '2018-11-05T11:14:33z'
}
export const oceanSchedule = {
  ...base,
  hub_route_key: 'OCEAN_HUB_ROUTE_KEY',
  mode_of_transport: 'ocean'
}
export const airSchedule = {
  hub_route_key: 'AIR_HUB_ROUTE_KEY',
  mode_of_transport: 'air',
  eta: '2018-11-18T11:14:33z',
  etd: '2018-11-13T11:14:33z',
  closing_date: '2018-11-01T11:14:33z'
}
export const truckSchedule = {
  hub_route_key: 'TRUCK_HUB_ROUTE_KEY',
  mode_of_transport: 'truck',
  eta: '2018-11-19T11:14:33z',
  etd: '2018-11-14T11:14:33z',
  closing_date: '2018-11-02T11:14:33z'
}
export const railSchedule = {
  hub_route_key: 'RAIL_HUB_ROUTE_KEY',
  mode_of_transport: 'rail',
  eta: '2018-11-20T11:14:33z',
  etd: '2018-11-15T11:14:33z',
  closing_date: '2018-11-03T11:14:33z'
}

export const schedules = [
  airSchedule,
  oceanSchedule,
  railSchedule,
  truckSchedule
]
