import {
  firstCargoItem,
  cargoItems,
  cargoItemTypes
} from './cargoItems'
import { schedules } from './schedules'
import { shipment } from './shipments'
import { documents } from './documents'
import { containers } from './containers'
import { results } from './results'

const aggregatedCargo = {
  ...firstCargoItem,
  volume: 12
}

const notifyees = [
  { first_name: 'John', last_name: 'Doe' },
  { first_name: 'Robert', last_name: 'Plant' },
  { first_name: 'James', last_name: 'Brows' }
]
const customs = {
  total: {
    total: {
      currency: 'EUR'
    }
  },
  import: {
    total: {
      currency: 'EUR'
    }
  },
  export: {
    total: {
      currency: 'EUR',
      value: 100
    }
  }
}

const addons = {
  customs_export_paper: true
}

const addresses = {
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
const hubs = {
  startHub: 'START_HUB',
  endHub: 'END_HUB'
}

export const shipmentData = {
  addons,
  addresses,
  aggregatedCargo,
  cargoItemTypes,
  cargoItems,
  contacts: [],
  containers,
  customs,
  dangerousGoods: false,
  documents,
  hubs,
  notifyees,
  results,
  schedule: { hub_route_key: 'OCEAN_HUB_ROUTE_KEY' },
  schedules,
  routes: [],
  shipment
}
