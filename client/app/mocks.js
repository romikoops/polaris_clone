export const identity = input => input

export const theme = {
  colors: {
    primary: '#333',
    secondary: '#fafafa'
  }
}

export const user = {
  guest: false,
  company_name: 'FOO_COMPANY',
  first_name: 'John',
  last_name: 'Doe',
  email: 'foo@bar.baz',
  phone: '6345789'
}

export const history = {
  push: identity
}

export const tenant = {
  data: {
    id: 123,
    theme,
    subdomain: 'foosubdomain'
  }
}

export const req = {
  schedule: [{}],
  total: 345,
  shipment: {}
}

const schedulesInShipmentData = [
  { hub_route_key: 'FOO_HUB_ROUTE_KEY' },
  { hub_route_key: 'BAR_HUB_ROUTE_KEY' }
]

export const shipmentInShipmentData = {
  schedules_charges: {
    FOO_HUB_ROUTE_KEY: { total: 7 },
    BAR_HUB_ROUTE_KEY: { total: 25 }
  },
  total_goods_value: {
    value: 15,
    currency: 'USD'
  },
  has_on_carriage: false,
  has_pre_carriage: false,
  notes: 'FOO_NOTES',
  cargo_notes: 'FOO_CARGO_NOTES',
  eori: 1234,
  incoterm_text: 'FOO_INCOTERM_TEXT',
  total_price: {
    value: 12,
    currency: 'USD'
  }
}

export const shipmentData = {
  contacts: [],
  shipment: shipmentInShipmentData,
  documents: [],
  cargoItems: [],
  containers: [],
  schedules: schedulesInShipmentData,
  locations: {
    startHub: 'FOO_START_HUB',
    endHub: 'FOO_END_HUB',
    destination: {
      street_number: 9,
      street: 'BAR_STREET',
      city: 'BAR_CITY',
      country: 'China',
      zip_code: 845321
    },
    origin: {
      street_number: 7,
      street: 'FOO_STREET',
      city: 'FOO_CITY',
      country: 'Germany',
      zip_code: 21177
    }
  }
}

export const match = {
  params: {}
}

export const shipments = {
  open: [],
  requested: [],
  finished: []
}

export const shipment = {
  id: 654,
  status: 'FOO_STATUS',
  clientName: 'FOO_CLIENT_NAME',
  planned_etd: 789,
  imc_reference: 'FOO_IMC_REFERENCE',
  schedule_set: []
}

export const location = {
  primary: true,
  id: 246,
  street_number: 579,
  street: 'FOO_STREET',
  city: 'FOO_CITY',
  zip_code: '22456',
  country: 'Germany'
}

export const address = {
  id: 13579,
  street_number: '1',
  street: 'Uhlandweg',
  city: 'Hamburg',
  zip_code: '22848',
  country: 'Germany'
}

export const hub = {
  location,
  name: 'FOO_HUB_NAME'
}

export const client = {
  first_name: 'Sebastian',
  last_name: 'Muller',
  email: 'muller55@yahoo.de',
  company_name: 'Mehristweniger',
  password: 'pwd'
}

export const route = {
  id: 24680
}

export const vehicleType = {
  id: 827364,
  name: 'FOO_VEHICLE_TYPE_NAME',
  mode_of_transport: 'FOO_VEHICLE_TYPE_TRANSPORT'
}

export const schedule = {
  hub_route_key: 'FOO_SCHEDULE_ROUTE_KEY',
  id: 555777,
  eta: 441188
}

export const charge = {
  id: 654297
}

export const locations = {
  origin: {},
  destination: {}
}

class MapMock {
  constructor (x) {
    this.x = x
  }
  bindTo () {
    return this.x
  }
  setContent () {
    return this.x
  }
  addListener () {
    return this.x
  }
}

export const gMaps = {
  InfoWindow: MapMock,
  LatLngBounds: MapMock,
  Map: MapMock,
  MapTypeId: { ROADMAP: '' },
  Marker: MapMock,
  Point: MapMock,
  Size: MapMock,
  places: { Autocomplete: MapMock }
}
