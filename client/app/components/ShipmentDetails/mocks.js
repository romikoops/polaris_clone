// Will remove it later
// ============================================
import { get } from 'lodash'

export const trucking = { preCarriage: { truckType: '' }, onCarriage: { truckType: '' } }
export const id = 4606
export const selectedDay = '2019-01-24T10:00:00.000Z'

export const ShipmentDetailsAvailableRoutes = [{
  itineraryId: 2863,
  itineraryName: 'Gothenburg - Qingdao',
  modeOfTransport: 'ocean',
  origin: {
    stopId: 4656, hubId: 3023, hubName: 'Gothenburg Port', nexusId: 597, nexusName: 'Gothenburg', latitude: 57.694253, longitude: 11.854048, country: 'SE', truckTypes: ['default']
  },
  destination: {
    stopId: 4657, hubId: 3027, hubName: 'Qingdao Port', nexusId: 601, nexusName: 'Qingdao', latitude: 36.083811, longitude: 120.323534, country: 'CN', truckTypes: []
  }
}, {
  itineraryId: 2958,
  itineraryName: 'Gothenburg - Qingdao',
  modeOfTransport: 'air',
  origin: {
    stopId: 4846, hubId: 3030, hubName: 'Gothenburg Airport', nexusId: 597, nexusName: 'Gothenburg', latitude: 57.694253, longitude: 11.854048, country: 'SE', truckTypes: ['default']
  },
  destination: {
    stopId: 4847, hubId: 3034, hubName: 'Qingdao Airport', nexusId: 601, nexusName: 'Qingdao', latitude: 36.083811, longitude: 120.323534, country: 'CN', truckTypes: []
  }
}]

export const ShipmentDetails = {
  availableRoutes: ShipmentDetailsAvailableRoutes,
  availableMots: ['ocean', 'air']
}

export const cargoItemTypes = [{
  id: 25, dimension_x: null, dimension_y: null, description: 'Pallet', area: null, created_at: '2018-06-27T17:28:28.431Z', updated_at: '2018-06-27T17:28:28.431Z', category: 'Pallet'
}, {
  id: 22, dimension_x: null, dimension_y: null, description: 'Carton', area: null, created_at: '2018-06-27T17:28:28.417Z', updated_at: '2018-06-27T17:28:28.417Z', category: 'Carton'
}, {
  id: 23, dimension_x: null, dimension_y: null, description: 'Crate', area: null, created_at: '2018-06-27T17:28:28.422Z', updated_at: '2018-06-27T17:28:28.422Z', category: 'Crate'
}, {
  id: 26, dimension_x: null, dimension_y: null, description: 'Bottle', area: null, created_at: '2018-06-27T17:28:28.436Z', updated_at: '2018-06-27T17:28:28.436Z', category: 'Bottle'
}, {
  id: 27, dimension_x: null, dimension_y: null, description: 'Stack', area: null, created_at: '2018-06-27T17:28:28.440Z', updated_at: '2018-06-27T17:28:28.440Z', category: 'Stack'
}, {
  id: 28, dimension_x: null, dimension_y: null, description: 'Drum', area: null, created_at: '2018-06-27T17:28:28.445Z', updated_at: '2018-06-27T17:28:28.445Z', category: 'Drum'
}, {
  id: 29, dimension_x: null, dimension_y: null, description: 'Skid', area: null, created_at: '2018-06-27T17:28:28.450Z', updated_at: '2018-06-27T17:28:28.450Z', category: 'Skid'
}, {
  id: 30, dimension_x: null, dimension_y: null, description: 'Barrel', area: null, created_at: '2018-06-27T17:28:28.454Z', updated_at: '2018-06-27T17:28:28.454Z', category: 'Barrel'
}]

export const maxDimensions = {
  general: {
    dimensionX: '590.0', dimensionY: '234.2', dimensionZ: '228.0', payloadInKg: '21770.0', chargeableWeight: '21770.0'
  },
  air: {
    dimensionX: '120.0', dimensionY: '100.0', dimensionZ: '150.0', payloadInKg: '1000.0', chargeableWeight: '1000.0'
  }
}

export const scope = {
  links: { about: '', legal: '' },
  terms: ['You verify that all the information provided above is true', 'You agree to the presented terms and conditions.', 'Demo is to discuss the validity of the presented prices with the product owners.'],
  fee_detail: 'key_and_name',
  closed_shop: false,
  has_customs: true,
  has_insurance: true,
  fixed_currency: false,
  dangerous_goods: false,
  cargo_info_level: 'hs_codes',
  carriage_options: { on_carriage: { export: 'optional', import: 'optional' }, pre_carriage: { export: 'optional', import: 'optional' } },
  detailed_billing: false,
  total_dimensions: true,
  consolidate_cargo: false,
  modes_of_transport: {
    air: { container: true, cargo_item: true }, rail: { container: true, cargo_item: true }, ocean: { container: true, cargo_item: true }, truck: { container: false, cargo_item: false }
  },
  show_beta_features: true,
  closed_registration: false,
  continuous_rounding: false,
  incoterm_info_level: 'text',
  non_stackable_goods: true,
  open_quotation_tool: false,
  customs_export_paper: false,
  fixed_exchange_rates: false,
  require_full_address: true,
  closed_quotation_tool: false
}

export const theme = {
  colors: {
    primary: '#0D5BA9', secondary: '#23802A', brightPrimary: '#2491FD', brightSecondary: '#25ED36'
  },
  logoWide: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_blue.png',
  logoLarge: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
  logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
  logoWhite: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png',
  background: 'https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg'
}

export const origin = {
  latitude: 57.694253, longitude: 11.854048, nexusId: 597, nexusName: 'Gothenburg', country: 'SE'
}
export const destination = {
  latitude: 36.083811, longitude: 120.323534, nexusId: 601, nexusName: 'Qingdao', country: 'CN'
}
export const cargoItem = {
  payloadInKg: 11, totalVolume: 0, totalWeight: 0, dimensionX: 7, dimensionY: 7, dimensionZ: 8, quantity: 7, cargoItemTypeId: 23, dangerousGoods: false, stackable: false
}

export const cargoItemAggregated = {
  payloadInKg: 0, totalVolume: 122, totalWeight: 346, dimensionX: 0, dimensionY: 0, dimensionZ: 0, quantity: 1, cargoItemTypeId: '', dangerousGoods: false, stackable: true
}

export const cargoItemContainer = {
  sizeClass: 'highCube', quantity: 14, dangerousGoods: false, weight: 16
}

export const cargoUnits = [cargoItem]

export const identity = x => x

export const importedProps = {
  ShipmentDetails,
  aggregatedCargo: false,
  cargoItemTypes,
  cargoUnits,
  destination,
  direction: 'export',
  id,
  loadType: 'cargo_item',
  maxDimensions,
  onCarriage: false,
  onChangeCargoUnitCheckbox: identity,
  onChangeCargoUnitInput: identity,
  onChangeCargoUnitSelect: identity,
  onDeleteUnit: identity,
  onUpdateCargoUnit: identity,
  origin,
  preCarriage: false,
  scope,
  selectedDay,
  theme,
  toggleModal: identity,
  trucking
}

export function logPath (props, path) {
  console.log(path, get(props, path, 'NO SUCH PATH'))
}

export function log (props) {
  let holder = '{\n'
  const declarations = []
  Object.keys(props).forEach((key) => {
    const toLog = `const ${key} = ${JSON.stringify(props[key])}`
    if (toLog.length < 150) console.log(toLog)
    declarations.push(toLog)

    holder = `${holder}\n  ${key},`
  })
  holder = `${holder}\n}`
  console.log(declarations.join('\n'))
  // console.log(holder)
  // console.log(JSON.stringify(props, null, 2))
}
