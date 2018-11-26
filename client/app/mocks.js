import { set, cloneDeep } from 'lodash'

/**
 * Checks if variable is an non-empty object
 *
 * True for `{a:1}`
 * Fase for `null, {}, [], [1,2,3]`
 */
const isObject = (x) => {
  const ok = x !== null && !Array.isArray(x) && typeof x === 'object'
  if (!ok) {
    return false
  }

  return Object.keys(x).length > 0
}
/* eslint-disable */
/**
 * Used in unit test to modify specific properties
 * with minimal lines of code
 *
 * You can specify `path` to be empty string
 * if the change affects more than one of object's branches
 */
export const change = (origin, pathRaw, rules) => {
  const willReturn = cloneDeep(origin)
  
  if (!isObject(rules)) {
    set(willReturn, pathRaw, rules)

    return willReturn
  }
  const path = pathRaw === '' ? '' : `${pathRaw}.`

  for (const ruleKey of Object.keys(rules)) {
    const rule = rules[ruleKey]
    if (!isObject(rule)) {
      set(
        willReturn,
        `${path}${ruleKey}`,
        rule
      )
      continue
    }
    Object.keys(rule).filter(subruleKey => !isObject(rule[subruleKey])).map((subruleKey) => {
      const subrule = rule[subruleKey]
      set(
        willReturn,
        `${path}${ruleKey}.${subruleKey}`,
        subrule
      )
    })
    Object.keys(rule).filter(subruleKey => isObject(rule[subruleKey])).map((subruleKey) => {
      const subrule = rule[subruleKey]
      Object.keys(subrule).map((deepKey) => {
        const deep = rule[subruleKey][deepKey]
        set(
          willReturn,
          `${path}${ruleKey}.${subruleKey}.${deepKey}`,
          deep
        )
      })
    })
  }

  return willReturn
}
/* eslint-enable */
export const identity = input => input

export const theme = {
  colors: {
    primary: '#333',
    secondary: '#fafafa'
  }
}

export const user = {
  role: { name: 'shipper' },
  company_name: 'FOO_COMPANY',
  currency: 'EUR',
  email: 'foo@bar.baz',
  first_name: 'John',
  guest: false,
  last_name: 'Doe',
  phone: '6345789'
}

export const users = {
  contactOne: {
    role: { name: 'shipper' },
    company_name: 'FOO_COMPANY',
    currency: 'EUR',
    email: 'foo2@bar.baz',
    first_name: 'John',
    guest: false,
    last_name: 'Doe',
    phone: '6345789'
  },
  contactTwo: {
    role: { name: 'shipper' },
    company_name: 'FOO_COMPANY',
    currency: 'EUR',
    email: 'foo2@bar.baz',
    first_name: 'John',
    guest: false,
    last_name: 'Doe',
    phone: '6345789'
  }
}
export const history = {
  push: identity
}

export const tenant = {
  id: 123,
  scope: {
    modes_of_transport: {
      ocean: {
        OCEAN_LOAD_TYPE: true
      },
      air: {},
      truck: {},
      rail: {}
    },
    closed_quotation_tool: true
  },
  theme,
  subdomain: 'foosubdomain'
}

export const req = {
  schedule: [{}],
  total: 345,
  shipment: {}
}

const schedulesInShipmentData = [
  { hub_route_key: 'OCEAN_HUB_ROUTE_KEY', mode_of_transport: 'ocean' },
  { hub_route_key: 'AIR_HUB_ROUTE_KEY', mode_of_transport: 'air' },
  { hub_route_key: 'TRUCK_HUB_ROUTE_KEY', mode_of_transport: 'truck' },
  { hub_route_key: 'RAIL_HUB_ROUTE_KEY', mode_of_transport: 'rail' }
]

export const shipmentInShipmentData = {
  load_type: 'OCEAN_LOAD_TYPE',
  selected_offer: { cargo: {}, total: { value: 77 } },
  schedules_charges: {
    OCEAN_HUB_ROUTE_KEY: { total: 40 },
    AIR_HUB_ROUTE_KEY: { total: 200 },
    TRUCK_HUB_ROUTE_KEY: { total: 75 },
    RAIL_HUB_ROUTE_KEY: { total: 125 }
  },
  total_goods_value: {
    value: 15,
    currency: 'USD'
  },
  trucking: {
    pre_carriage: { trucking_time_in_seconds: 55 },
    on_carriage: { trucking_time_in_seconds: 55 }
  },
  has_on_carriage: false,
  has_pre_carriage: false,
  planned_eta: '11/12/2018',
  planned_etd: '12/1/2019',
  notes: 'FOO_NOTES',
  cargo_notes: 'FOO_CARGO_NOTES',
  eori: 1234,
  incoterm_text: 'FOO_INCOTERM_TEXT',
  total_price: {
    value: 12,
    currency: 'USD'
  },
  cargo_count: 1
}

export const shipmentData = {
  contacts: [],
  shipment: shipmentInShipmentData,
  documents: [],
  cargoItems: [],
  containers: [],
  schedules: schedulesInShipmentData,
  addresses: {
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
  direction: 'export',
  finished: [],
  open: [],
  requested: [],
  archived: [],
  rejected: []
}

export const shipment = {
  origin_hub: { name: 'FOO_ORIGIN_HUB' },
  destination_hub: { name: 'FOO_DESTINATION_HUB' },
  selected_offer: { cargo: {}, total: { value: 77 } },
  id: 654,
  cargo_units: [{
    dimension_x: 107.0,
    dimension_y: 63.0,
    dimension_z: 67.0,
    quantity: 2
  }],
  status: 'FOO_STATUS',
  clientName: 'FOO_CLIENT_NAME',
  planned_etd: 789,
  imc_reference: 'FOO_IMC_REFERENCE',
  schedule_set: [],
  service_level: 'standard',
  total_price: {
    value: '200.99',
    currency: 'USD'
  },
  cargo_count: 2
}

export const address = {
  primary: true,
  id: 246,
  street_number: 579,
  streetNumber: 579,
  geocodedAddress: 'FOO_GEOCODED_ADDRESS',
  street: 'FOO_STREET',
  city: 'FOO_CITY',
  zip_code: '22456',
  zipCode: '22456',
  country: 'Germany'
}

export const address2 = {
  id: 13579,
  street_number: '1',
  street: 'Uhlandweg',
  city: 'Hamburg',
  zip_code: '22848',
  country: 'Germany'
}

export const hub = {
  address,
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

export const addresses = {
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
