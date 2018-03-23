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
  { hub_route_key: 'FOO_HUB_ROUTE_KEY' }
]

const shipmentInShipmentData = {
  schedules_charges: {
    [schedulesInShipmentData[0].hub_route_key]: {
      foo: 'FOO_ROUTE_KEY'
    }
  },
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
    endHub: 'FOO_END_HUB'
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

export const gMaps = {
  Point: identity,
  Size: identity,
  Marker: identity,
  LatLngBounds: identity,
  MapTypeId: {},
  Map: identity,
  places: {},
  InfoWindow: identity
}
