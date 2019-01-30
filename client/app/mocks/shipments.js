import { firstAddress } from './address'

const selected_offer = {
  cargo: {},
  customs: {
    hasUnknown: false,
    val: 12
  },
  insurance: { val: 5 },
  total: { value: 87 }
}

const schedules_charges = {
  AIR_HUB_ROUTE_KEY: { total: 200 },
  OCEAN_HUB_ROUTE_KEY: { total: 40 },
  RAIL_HUB_ROUTE_KEY: { total: 125 },
  TRUCK_HUB_ROUTE_KEY: { total: 75 }
}
const trucking = {
  has_pre_carriage: false,
  has_on_carriage: false,
  pre_carriage: { trucking_time_in_seconds: 55 },
  on_carriage: { trucking_time_in_seconds: 28 }
}
const cargo_units = [{
  dimension_x: 107.0,
  dimension_y: 63.0,
  dimension_z: 67.0,
  quantity: 2
}]
const origin_hub = {
  name: 'SHIPMENT_ORIGIN_HUB',
  startHub: { address: firstAddress }
}
const destination_hub = {
  name: 'SHIPMENT_DESTINATION_HUB',
  startHub: { address: { } }
}

export const shipment = {
  origin: {
    fullAddress: 'SHIPMENT_ORIGIN_FULL_ADDRESS'
  },
  destination: {
    fullAddress: 'SHIPMENT_DESTINATION_FULL_ADDRESS'
  },
  booking_placed_at: '2018-11-01T11:14:33z',
  updated_at: '2018-11-01T18:14:33z',
  cargo_count: 2,
  cargo_notes: 'SHIPMENT_CARGO_NOTES',
  cargo_units,
  load_type: 'cargo_item',
  cargo_items_attributes: [],
  containers_attributes: [],
  clientName: 'SHIPMENT_CLIENT_NAME',
  delivery_address: 'SHIPMENT_DELIVERY_ADDRESS',
  destination_hub,
  direction: 'import',
  eori: 1234,
  has_on_carriage: false,
  has_pre_carriage: false,
  id: 654,
  imc_reference: 'SHIPMENT_IMC_REFERENCE',
  incoterm: 'SHIPMENT_INCOTERM',
  incoterm_text: 'SHIPMENT_INCOTERM_TEXT',
  notes: 'SHIPMENT_NOTES',
  origin_hub,
  pickup_address: 'SHIPMENT_PICKUP_ADDRESS',
  planned_pickup_date: '2018-12-08T04:30:08z',
  planned_eta: '2018-12-01T18:14:33z',
  planned_etd: '2018-11-12T12:37:08z',
  planned_origin_drop_off_date: '2018-12-01T22:14:33z',
  schedules_charges,
  selected_offer,
  schedule_set: [
    { hub_route_key: 'SHIPMENT_SCHEDULE_SET_HUB_ROUTE_KEY' }
  ],
  service_level: 'standard',
  status: 'finished',
  total_goods_value: {
    value: 150000,
    currency: 'USD'
  },
  total_price: {
    value: 137550,
    currency: 'USD'
  },
  trucking
}
