export const trucking = { preCarriage: { truckType: '' }, onCarriage: { truckType: '' } }
export const id = 4606
export const selectedDay = '2019-01-24T10:00:00.000Z'
export const lastAvailableDate = '2019-03-12T12:00:00.000Z'

export const ShipmentDetailsAvailableRoutes = [{
  itineraryId: 2863,
  itineraryName: 'Gothenburg - Qingdao',
  modeOfTransport: 'ocean',
  cargoClasses: ['lcl', 'fcl_20', 'fcl_40', 'fcl_40_hq'],
  origin: {
    stopId: 4656,
    hubId: 3023,
    hubName: 'Gothenburg Port',
    nexusId: 597,
    nexusName: 'Gothenburg',
    latitude: 57.694253,
    longitude: 11.854048,
    country: 'SE',
    truckTypes: ['default']
  },
  destination: {
    stopId: 4657,
    hubId: 3027,
    hubName: 'Qingdao Port',
    nexusId: 601,
    nexusName: 'Qingdao',
    latitude: 36.083811,
    longitude: 120.323534,
    country: 'CN',
    truckTypes: []
  }
}, {
  itineraryId: 2958,
  itineraryName: 'Gothenburg - Qingdao',
  modeOfTransport: 'air',
  cargoClasses: ['lcl'],
  origin: {
    stopId: 4846,
    hubId: 3030,
    hubName: 'Gothenburg Airport',
    nexusId: 597,
    nexusName: 'Gothenburg',
    latitude: 57.694253,
    longitude: 11.854048,
    country: 'SE',
    truckTypes: ['default']
  },
  destination: {
    stopId: 4847,
    hubId: 3034,
    hubName: 'Qingdao Airport',
    nexusId: 601,
    nexusName: 'Qingdao',
    latitude: 36.083811,
    longitude: 120.323534,
    country: 'CN',
    truckTypes: []
  }
}]

export const allMots = ['ocean', 'air', 'rail']
export const availableMots = ['ocean', 'air']

export const ShipmentDetails = {
  availableRoutes: ShipmentDetailsAvailableRoutes,
  availableMots
}

export const cargoItemTypes = [
  {
    id: 25,
    width: null,
    length: null,
    description: 'Pallet',
    area: null,
    created_at: '2018-06-27T17:28:28.431Z',
    updated_at: '2018-06-27T17:28:28.431Z',
    category: 'Pallet'
  },
  {
    id: 22,
    width: null,
    length: null,
    description: 'Carton',
    area: null,
    created_at: '2018-06-27T17:28:28.417Z',
    updated_at: '2018-06-27T17:28:28.417Z',
    category: 'Carton'
  },
  {
    id: 23,
    width: null,
    length: null,
    description: 'Crate',
    area: null,
    created_at: '2018-06-27T17:28:28.422Z',
    updated_at: '2018-06-27T17:28:28.422Z',
    category: 'Crate'
  },
  {
    id: 26,
    width: null,
    length: null,
    description: 'Bottle',
    area: null,
    created_at: '2018-06-27T17:28:28.436Z',
    updated_at: '2018-06-27T17:28:28.436Z',
    category: 'Bottle'
  },
  {
    id: 27,
    width: null,
    length: null,
    description: 'Stack',
    area: null,
    created_at: '2018-06-27T17:28:28.440Z',
    updated_at: '2018-06-27T17:28:28.440Z',
    category: 'Stack'
  },
  {
    id: 28,
    width: null,
    length: null,
    description: 'Drum',
    area: null,
    created_at: '2018-06-27T17:28:28.445Z',
    updated_at: '2018-06-27T17:28:28.445Z',
    category: 'Drum'
  },
  {
    id: 29,
    width: null,
    length: null,
    description: 'Skid',
    area: null,
    created_at: '2018-06-27T17:28:28.450Z',
    updated_at: '2018-06-27T17:28:28.450Z',
    category: 'Skid'
  },
  {
    id: 30,
    width: null,
    length: null,
    description: 'Barrel',
    area: null,
    created_at: '2018-06-27T17:28:28.454Z',
    updated_at: '2018-06-27T17:28:28.454Z',
    category: 'Barrel'
  }
]

export const maxDimensions = {
  general: {
    width: '590.0', length: '234.2', height: '228.0', payloadInKg: '21770.0', chargeableWeight: '21770.0'
  },
  air: {
    width: '120.0', length: '100.0', height: '150.0', payloadInKg: '1000.0', chargeableWeight: '1000.0'
  }
}

export const scope = {
  links: { about: '', legal: '' },
  terms: [
    'You verify that all the information provided above is true',
    'You agree to the presented terms and conditions.',
    'Demo is to discuss the validity of the presented prices with the product owners.'
  ],
  fee_detail: 'key_and_name',
  closed_shop: false,
  has_customs: true,
  has_insurance: true,
  fixed_currency: false,
  dangerous_goods: false,
  cargo_info_level: 'hs_codes',
  carriage_options: {
    on_carriage: {
      export: 'optional', import: 'optional'
    },
    pre_carriage: {
      export: 'optional', import: 'optional'
    }
  },
  detailed_billing: false,
  total_dimensions: true,
  consolidate_cargo: false,
  modes_of_transport: {
    air: {
      container: true, cargo_item: true
    },
    rail: {
      container: true, cargo_item: true
    },
    ocean: {
      container: true, cargo_item: true
    },
    truck: {
      container: false, cargo_item: false
    }
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
  closed_quotation_tool: false,
  address_fields: true
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
  payloadInKg: 223,
  totalVolume: 0,
  totalWeight: 0,
  width: 5,
  length: 132,
  height: 12,
  quantity: 6,
  cargoItemTypeId: 23,
  dangerousGoods: false,
  stackable: true
}

export const cargoItemAggregated = {
  payloadInKg: 0,
  totalVolume: 122,
  totalWeight: 346,
  width: 0,
  length: 0,
  height: 0,
  quantity: 1,
  cargoItemTypeId: '',
  dangerousGoods: false,
  stackable: true
}

export const cargoItemContainer = {
  sizeClass: 'highCube', quantity: 14, dangerousGoods: false, weight: 16
}


export const maxDimensionsToApply = {
  width: '590.0', length: '234.2', height: '228.0', payloadInKg: '21770.0', chargeableWeight: '21770.0'
}

export const cargoUnits = [cargoItem]

const identity = x => x

export const cargoUnitProps = {
  ShipmentDetails,
  aggregatedCargo: false,
  cargoItemTypes,
  cargoUnits,
  destination,
  direction: 'export',
  id,
  loadType: 'cargo_item',
  maxDimensions,
  maxAggregateDimensions: maxDimensions,
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

export const tenant = {
  id: 3,
  theme: {
    colors: {
      primary: '#0D5BA9',
      secondary: '#23802A',
      brightPrimary: '#2491FD',
      brightSecondary: '#25ED36'
    },
    logoWide: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_blue.png',
    logoLarge: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
    logoSmall: 'https://assets.itsmycargo.com/assets/logos/logo_box.png',
    logoWhite: 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png',
    background: 'https://assets.itsmycargo.com/assets/images/cropped_banner_2.jpg'
  },
  emails: {
    sales: {
      air: 'sales@demo.com',
      rail: 'sales@demo.com',
      ocean: 'sales@demo.com',
      general: 'sales@demo.com'
    },
    support: {
      air: 'imc.air@demo.com',
      rail: 'imc.rail@demo.com',
      ocean: 'imc.sea@demo.com',
      general: 'support@demo.com'
    }
  },
  subdomain: 'demo',
  created_at: '2018-05-15T10:09:24.288Z',
  updated_at: '2018-12-12T17:09:04.594Z',
  phones: {
    main: '+46 31-85 32 00',
    support: '0173042031020'
  },
  addresses: {
    main: 'Brooktorkai 7, 20457 Hamburg, Germany',
    components: []
  },
  name: 'Demo',
  scope: {
    links: {
      about: '',
      legal: ''
    },
    terms: [
      'You verify that all the information provided above is true',
      'You agree to the presented terms and conditions.',
      'Demo is to discuss the validity of the presented prices with the product owners.'
    ],
    fee_detail: 'key_and_name',
    closed_shop: false,
    has_customs: true,
    has_insurance: true,
    fixed_currency: false,
    dangerous_goods: false,
    cargo_info_level: 'hs_codes',
    carriage_options: {
      on_carriage: {
        export: 'optional',
        import: 'optional'
      },
      pre_carriage: {
        export: 'optional',
        import: 'optional'
      }
    },
    detailed_billing: false,
    total_dimensions: true,
    consolidate_cargo: false,
    modes_of_transport: {
      air: {
        container: true,
        cargo_item: true
      },
      rail: {
        container: true,
        cargo_item: true
      },
      ocean: {
        container: true,
        cargo_item: true
      },
      truck: {
        container: false,
        cargo_item: false
      }
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
  },
  currency: 'EUR',
  web: {
    index: 'index.html',
    subdomain: 'demo',
    cloudfront: 'E19KMYH87T6B3G'
  },
  email_links: {
    confirmation_instructions: [
      {
        href: 'www.example.com',
        text: 'All assignments will be performed in accordance with the General Conditions of the Nordic Association of Freight Forwarders (NSAB 2015)',
        link_text: 'Nordic Association of Freight Forwarders'
      },
      {
        href: 'www.example2.com',
        text: 'This is just an example2.',
        link_text: 'example2'
      }
    ]
  }
}

export const user = {
  id: 1,
  email: 'shipper@itsmycargo.com',
  tenant_id: 3,
  uid: '3***shipper@itsmycargo.com',
  provider: 'tenant_email',
  nickname: null,
  image: null,
  company_name: 'ItsMyCargo',
  first_name: 'Someone',
  last_name: 'Staff',
  phone: '123456789',
  guest: false,
  currency: 'EUR',
  vat_number: null,
  allow_password_change: false,
  optin_status: {
    id: 1,
    cookies: true,
    tenant: true,
    itsmycargo: true
  },
  external_id: null,
  agency_id: null,
  internal: null,
  role: {
    id: 2,
    name: 'shipper'
  }
}

export const routes = [
  {
    itineraryId: 2849,
    itineraryName: 'Shanghai - Gothenburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4628,
      hubId: 3025,
      hubName: 'Shanghai Port',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4629,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2852,
    itineraryName: 'Gothenburg - Shanghai',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4634,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4635,
      hubId: 3025,
      hubName: 'Shanghai Port',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2853,
    itineraryName: 'Gothenburg - Ningbo',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4636,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4637,
      hubId: 3024,
      hubName: 'Ningbo Port',
      nexusId: 598,
      nexusName: 'Ningbo',
      latitude: 29.929641,
      longitude: 121.84597,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2858,
    itineraryName: 'Stockholm - Shanghai',
    modeOfTransport: 'air',
    origin: {
      stopId: 4646,
      hubId: 3037,
      hubName: 'Stockholm Airport',
      nexusId: 604,
      nexusName: 'Stockholm',
      latitude: 59.650856,
      longitude: 17.931097,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4647,
      hubId: 3032,
      hubName: 'Shanghai Airport',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2861,
    itineraryName: 'Gothenburg - Dalian',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4652,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4653,
      hubId: 3026,
      hubName: 'Dalian Port',
      nexusId: 600,
      nexusName: 'Dalian',
      latitude: 38.926974,
      longitude: 121.655672,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2863,
    itineraryName: 'Gothenburg - Qingdao',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4656,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4657,
      hubId: 3027,
      hubName: 'Qingdao Port',
      nexusId: 601,
      nexusName: 'Qingdao',
      latitude: 36.083811,
      longitude: 120.323534,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2866,
    itineraryName: 'Gothenburg - Shenzhen',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4662,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4663,
      hubId: 3028,
      hubName: 'Shenzhen Port',
      nexusId: 602,
      nexusName: 'Shenzhen',
      latitude: 22.544083,
      longitude: 113.899893,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2869,
    itineraryName: 'Gothenburg - Tianjin',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4668,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4669,
      hubId: 3029,
      hubName: 'Tianjin Port',
      nexusId: 603,
      nexusName: 'Tianjin',
      latitude: 38.993914,
      longitude: 117.721024,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2871,
    itineraryName: 'Dalian - Gothenburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4672,
      hubId: 3026,
      hubName: 'Dalian Port',
      nexusId: 600,
      nexusName: 'Dalian',
      latitude: 38.926974,
      longitude: 121.655672,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4673,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2873,
    itineraryName: 'Qingdao - Gothenburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4676,
      hubId: 3027,
      hubName: 'Qingdao Port',
      nexusId: 601,
      nexusName: 'Qingdao',
      latitude: 36.083811,
      longitude: 120.323534,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4677,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2876,
    itineraryName: 'Ningbo - Gothenburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4682,
      hubId: 3024,
      hubName: 'Ningbo Port',
      nexusId: 598,
      nexusName: 'Ningbo',
      latitude: 29.929641,
      longitude: 121.84597,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4683,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2878,
    itineraryName: 'Shenzhen - Gothenburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4686,
      hubId: 3028,
      hubName: 'Shenzhen Port',
      nexusId: 602,
      nexusName: 'Shenzhen',
      latitude: 22.544083,
      longitude: 113.899893,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4687,
      hubId: 3023,
      hubName: 'Gothenburg Port',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2880,
    itineraryName: 'Shanghai - Gothenburg',
    modeOfTransport: 'air',
    origin: {
      stopId: 4690,
      hubId: 3032,
      hubName: 'Shanghai Airport',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4691,
      hubId: 3030,
      hubName: 'Gothenburg Airport',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2884,
    itineraryName: 'Shanghai - Stockholm',
    modeOfTransport: 'air',
    origin: {
      stopId: 4698,
      hubId: 3032,
      hubName: 'Shanghai Airport',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4699,
      hubId: 3037,
      hubName: 'Stockholm Airport',
      nexusId: 604,
      nexusName: 'Stockholm',
      latitude: 59.650856,
      longitude: 17.931097,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2887,
    itineraryName: 'Shanghai - Malmo',
    modeOfTransport: 'air',
    origin: {
      stopId: 4704,
      hubId: 3032,
      hubName: 'Shanghai Airport',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4705,
      hubId: 3038,
      hubName: 'Malmo Airport',
      nexusId: 605,
      nexusName: 'Malmo',
      latitude: 55.535558,
      longitude: 13.363027,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2889,
    itineraryName: 'Ningbo - Gothenburg',
    modeOfTransport: 'air',
    origin: {
      stopId: 4708,
      hubId: 3031,
      hubName: 'Ningbo Airport',
      nexusId: 598,
      nexusName: 'Ningbo',
      latitude: 29.929641,
      longitude: 121.84597,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4709,
      hubId: 3030,
      hubName: 'Gothenburg Airport',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2892,
    itineraryName: 'Ningbo - Stockholm',
    modeOfTransport: 'air',
    origin: {
      stopId: 4714,
      hubId: 3031,
      hubName: 'Ningbo Airport',
      nexusId: 598,
      nexusName: 'Ningbo',
      latitude: 29.929641,
      longitude: 121.84597,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4715,
      hubId: 3037,
      hubName: 'Stockholm Airport',
      nexusId: 604,
      nexusName: 'Stockholm',
      latitude: 59.650856,
      longitude: 17.931097,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2895,
    itineraryName: 'Ningbo - Malmo',
    modeOfTransport: 'air',
    origin: {
      stopId: 4720,
      hubId: 3031,
      hubName: 'Ningbo Airport',
      nexusId: 598,
      nexusName: 'Ningbo',
      latitude: 29.929641,
      longitude: 121.84597,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4721,
      hubId: 3038,
      hubName: 'Malmo Airport',
      nexusId: 605,
      nexusName: 'Malmo',
      latitude: 55.535558,
      longitude: 13.363027,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2898,
    itineraryName: 'Qingdao - Gothenburg',
    modeOfTransport: 'air',
    origin: {
      stopId: 4726,
      hubId: 3034,
      hubName: 'Qingdao Airport',
      nexusId: 601,
      nexusName: 'Qingdao',
      latitude: 36.083811,
      longitude: 120.323534,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4727,
      hubId: 3030,
      hubName: 'Gothenburg Airport',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2901,
    itineraryName: 'Qingdao - Stockholm',
    modeOfTransport: 'air',
    origin: {
      stopId: 4732,
      hubId: 3034,
      hubName: 'Qingdao Airport',
      nexusId: 601,
      nexusName: 'Qingdao',
      latitude: 36.083811,
      longitude: 120.323534,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4733,
      hubId: 3037,
      hubName: 'Stockholm Airport',
      nexusId: 604,
      nexusName: 'Stockholm',
      latitude: 59.650856,
      longitude: 17.931097,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2905,
    itineraryName: 'Qingdao - Malmo',
    modeOfTransport: 'air',
    origin: {
      stopId: 4740,
      hubId: 3034,
      hubName: 'Qingdao Airport',
      nexusId: 601,
      nexusName: 'Qingdao',
      latitude: 36.083811,
      longitude: 120.323534,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4741,
      hubId: 3038,
      hubName: 'Malmo Airport',
      nexusId: 605,
      nexusName: 'Malmo',
      latitude: 55.535558,
      longitude: 13.363027,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2908,
    itineraryName: 'Shenzhen - Gothenburg',
    modeOfTransport: 'air',
    origin: {
      stopId: 4746,
      hubId: 3035,
      hubName: 'Shenzhen Airport',
      nexusId: 602,
      nexusName: 'Shenzhen',
      latitude: 22.544083,
      longitude: 113.899893,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4747,
      hubId: 3030,
      hubName: 'Gothenburg Airport',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2911,
    itineraryName: 'Shenzhen - Stockholm',
    modeOfTransport: 'air',
    origin: {
      stopId: 4752,
      hubId: 3035,
      hubName: 'Shenzhen Airport',
      nexusId: 602,
      nexusName: 'Shenzhen',
      latitude: 22.544083,
      longitude: 113.899893,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4753,
      hubId: 3037,
      hubName: 'Stockholm Airport',
      nexusId: 604,
      nexusName: 'Stockholm',
      latitude: 59.650856,
      longitude: 17.931097,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2915,
    itineraryName: 'Shenzhen - Malmo',
    modeOfTransport: 'air',
    origin: {
      stopId: 4760,
      hubId: 3035,
      hubName: 'Shenzhen Airport',
      nexusId: 602,
      nexusName: 'Shenzhen',
      latitude: 22.544083,
      longitude: 113.899893,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 4761,
      hubId: 3038,
      hubName: 'Malmo Airport',
      nexusId: 605,
      nexusName: 'Malmo',
      latitude: 55.535558,
      longitude: 13.363027,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2918,
    itineraryName: 'Stockholm - Hong Kong',
    modeOfTransport: 'air',
    origin: {
      stopId: 4766,
      hubId: 3037,
      hubName: 'Stockholm Airport',
      nexusId: 604,
      nexusName: 'Stockholm',
      latitude: 59.650856,
      longitude: 17.931097,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4767,
      hubId: 3039,
      hubName: 'Hong Kong Airport',
      nexusId: 606,
      nexusName: 'Hong Kong',
      latitude: 22.316265,
      longitude: 113.939724,
      country: 'HK',
      truckTypes: []
    }
  },
  {
    itineraryId: 2921,
    itineraryName: 'Stockholm - Ningbo',
    modeOfTransport: 'air',
    origin: {
      stopId: 4772,
      hubId: 3037,
      hubName: 'Stockholm Airport',
      nexusId: 604,
      nexusName: 'Stockholm',
      latitude: 59.650856,
      longitude: 17.931097,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4773,
      hubId: 3031,
      hubName: 'Ningbo Airport',
      nexusId: 598,
      nexusName: 'Ningbo',
      latitude: 29.929641,
      longitude: 121.84597,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2925,
    itineraryName: 'Stockholm - Qingdao',
    modeOfTransport: 'air',
    origin: {
      stopId: 4780,
      hubId: 3037,
      hubName: 'Stockholm Airport',
      nexusId: 604,
      nexusName: 'Stockholm',
      latitude: 59.650856,
      longitude: 17.931097,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4781,
      hubId: 3034,
      hubName: 'Qingdao Airport',
      nexusId: 601,
      nexusName: 'Qingdao',
      latitude: 36.083811,
      longitude: 120.323534,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2928,
    itineraryName: 'Stockholm - Shenzhen',
    modeOfTransport: 'air',
    origin: {
      stopId: 4786,
      hubId: 3037,
      hubName: 'Stockholm Airport',
      nexusId: 604,
      nexusName: 'Stockholm',
      latitude: 59.650856,
      longitude: 17.931097,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4787,
      hubId: 3035,
      hubName: 'Shenzhen Airport',
      nexusId: 602,
      nexusName: 'Shenzhen',
      latitude: 22.544083,
      longitude: 113.899893,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2936,
    itineraryName: 'Gothenburg - Shanghai',
    modeOfTransport: 'air',
    origin: {
      stopId: 4802,
      hubId: 3030,
      hubName: 'Gothenburg Airport',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4803,
      hubId: 3032,
      hubName: 'Shanghai Airport',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2938,
    itineraryName: 'Malmo - Shanghai',
    modeOfTransport: 'air',
    origin: {
      stopId: 4806,
      hubId: 3038,
      hubName: 'Malmo Airport',
      nexusId: 605,
      nexusName: 'Malmo',
      latitude: 55.535558,
      longitude: 13.363027,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4807,
      hubId: 3032,
      hubName: 'Shanghai Airport',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2939,
    itineraryName: 'Malmo - Hong Kong',
    modeOfTransport: 'air',
    origin: {
      stopId: 4808,
      hubId: 3038,
      hubName: 'Malmo Airport',
      nexusId: 605,
      nexusName: 'Malmo',
      latitude: 55.535558,
      longitude: 13.363027,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4809,
      hubId: 3039,
      hubName: 'Hong Kong Airport',
      nexusId: 606,
      nexusName: 'Hong Kong',
      latitude: 22.316265,
      longitude: 113.939724,
      country: 'HK',
      truckTypes: []
    }
  },
  {
    itineraryId: 2942,
    itineraryName: 'Malmo - Ningbo',
    modeOfTransport: 'air',
    origin: {
      stopId: 4814,
      hubId: 3038,
      hubName: 'Malmo Airport',
      nexusId: 605,
      nexusName: 'Malmo',
      latitude: 55.535558,
      longitude: 13.363027,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4815,
      hubId: 3031,
      hubName: 'Ningbo Airport',
      nexusId: 598,
      nexusName: 'Ningbo',
      latitude: 29.929641,
      longitude: 121.84597,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2946,
    itineraryName: 'Malmo - Qingdao',
    modeOfTransport: 'air',
    origin: {
      stopId: 4822,
      hubId: 3038,
      hubName: 'Malmo Airport',
      nexusId: 605,
      nexusName: 'Malmo',
      latitude: 55.535558,
      longitude: 13.363027,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4823,
      hubId: 3034,
      hubName: 'Qingdao Airport',
      nexusId: 601,
      nexusName: 'Qingdao',
      latitude: 36.083811,
      longitude: 120.323534,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2950,
    itineraryName: 'Malmo - Shenzhen',
    modeOfTransport: 'air',
    origin: {
      stopId: 4830,
      hubId: 3038,
      hubName: 'Malmo Airport',
      nexusId: 605,
      nexusName: 'Malmo',
      latitude: 55.535558,
      longitude: 13.363027,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4831,
      hubId: 3035,
      hubName: 'Shenzhen Airport',
      nexusId: 602,
      nexusName: 'Shenzhen',
      latitude: 22.544083,
      longitude: 113.899893,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2951,
    itineraryName: 'Gothenburg - Hong Kong',
    modeOfTransport: 'air',
    origin: {
      stopId: 4832,
      hubId: 3030,
      hubName: 'Gothenburg Airport',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4833,
      hubId: 3039,
      hubName: 'Hong Kong Airport',
      nexusId: 606,
      nexusName: 'Hong Kong',
      latitude: 22.316265,
      longitude: 113.939724,
      country: 'HK',
      truckTypes: []
    }
  },
  {
    itineraryId: 2955,
    itineraryName: 'Gothenburg - Ningbo',
    modeOfTransport: 'air',
    origin: {
      stopId: 4840,
      hubId: 3030,
      hubName: 'Gothenburg Airport',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4841,
      hubId: 3031,
      hubName: 'Ningbo Airport',
      nexusId: 598,
      nexusName: 'Ningbo',
      latitude: 29.929641,
      longitude: 121.84597,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2958,
    itineraryName: 'Gothenburg - Qingdao',
    modeOfTransport: 'air',
    origin: {
      stopId: 4846,
      hubId: 3030,
      hubName: 'Gothenburg Airport',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4847,
      hubId: 3034,
      hubName: 'Qingdao Airport',
      nexusId: 601,
      nexusName: 'Qingdao',
      latitude: 36.083811,
      longitude: 120.323534,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2961,
    itineraryName: 'Gothenburg - Shenzhen',
    modeOfTransport: 'air',
    origin: {
      stopId: 4852,
      hubId: 3030,
      hubName: 'Gothenburg Airport',
      nexusId: 597,
      nexusName: 'Gothenburg',
      latitude: 57.694253,
      longitude: 11.854048,
      country: 'SE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4853,
      hubId: 3035,
      hubName: 'Shenzhen Airport',
      nexusId: 602,
      nexusName: 'Shenzhen',
      latitude: 22.544083,
      longitude: 113.899893,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 2964,
    itineraryName: 'Shanghai - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4858,
      hubId: 3025,
      hubName: 'Shanghai Port',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4859,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 2966,
    itineraryName: 'Hamburg - Shanghai',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 4861,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 4862,
      hubId: 3025,
      hubName: 'Shanghai Port',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11851,
    itineraryName: 'Hamburg - Bangkok',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22630,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22631,
      hubId: 5484,
      hubName: 'Bangkok Port',
      nexusId: 2808,
      nexusName: 'Bangkok',
      latitude: 13.7233786,
      longitude: 100.7838827,
      country: 'TH',
      truckTypes: []
    }
  },
  {
    itineraryId: 11852,
    itineraryName: 'Hamburg - Beijing',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22632,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22633,
      hubId: 5491,
      hubName: 'Beijing Port',
      nexusId: 2815,
      nexusName: 'Beijing',
      latitude: 39.9041999,
      longitude: 116.4073963,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 11853,
    itineraryName: 'Hamburg - Busan',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22634,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22635,
      hubId: 5521,
      hubName: 'Busan Port',
      nexusId: 2845,
      nexusName: 'Busan',
      latitude: 35.1795543,
      longitude: 129.0756416,
      country: 'KR',
      truckTypes: []
    }
  },
  {
    itineraryId: 11854,
    itineraryName: 'Hamburg - Chennai',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22636,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22637,
      hubId: 5552,
      hubName: 'Chennai Port',
      nexusId: 2876,
      nexusName: 'Chennai',
      latitude: 13.0826802,
      longitude: 80.2707184,
      country: 'IN',
      truckTypes: []
    }
  },
  {
    itineraryId: 11855,
    itineraryName: 'Hamburg - Dubai',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22638,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22639,
      hubId: 5600,
      hubName: 'Dubai Port',
      nexusId: 2923,
      nexusName: 'Dubai',
      latitude: 25.2048493,
      longitude: 55.2707828,
      country: 'AE',
      truckTypes: []
    }
  },
  {
    itineraryId: 11856,
    itineraryName: 'Hamburg - Ho Chi Minh',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22640,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22641,
      hubId: 5656,
      hubName: 'Ho Chi Minh Port',
      nexusId: 2978,
      nexusName: 'Ho Chi Minh',
      latitude: 10.8230989,
      longitude: 106.6296638,
      country: 'VN',
      truckTypes: []
    }
  },
  {
    itineraryId: 11857,
    itineraryName: 'Hamburg - Hong Kong',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22642,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22643,
      hubId: 3042,
      hubName: 'Hong Kong Port',
      nexusId: 606,
      nexusName: 'Hong Kong',
      latitude: 22.316265,
      longitude: 113.939724,
      country: 'HK',
      truckTypes: []
    }
  },
  {
    itineraryId: 11858,
    itineraryName: 'Hamburg - Jakarta',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22644,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22645,
      hubId: 5679,
      hubName: 'Jakarta Port',
      nexusId: 3001,
      nexusName: 'Jakarta',
      latitude: -6.17511,
      longitude: 106.8650395,
      country: 'ID',
      truckTypes: []
    }
  },
  {
    itineraryId: 11859,
    itineraryName: 'Hamburg - Jeddah',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22646,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22647,
      hubId: 5682,
      hubName: 'Jeddah Port',
      nexusId: 3004,
      nexusName: 'Jeddah',
      latitude: 21.485811,
      longitude: 39.1925048,
      country: 'SA',
      truckTypes: []
    }
  },
  {
    itineraryId: 11860,
    itineraryName: 'Hamburg - Kaohsiung',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22648,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22649,
      hubId: 5691,
      hubName: 'Kaohsiung Port',
      nexusId: 3013,
      nexusName: 'Kaohsiung',
      latitude: 22.6272784,
      longitude: 120.3014353,
      country: 'TW',
      truckTypes: []
    }
  },
  {
    itineraryId: 11861,
    itineraryName: 'Hamburg - Keelung',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22650,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22651,
      hubId: 5694,
      hubName: 'Keelung Port',
      nexusId: 3016,
      nexusName: 'Keelung',
      latitude: 23.69781,
      longitude: 120.960515,
      country: 'TW',
      truckTypes: []
    }
  },
  {
    itineraryId: 11862,
    itineraryName: 'Hamburg - Los Angeles',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22652,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22653,
      hubId: 5745,
      hubName: 'Los Angeles Port',
      nexusId: 3067,
      nexusName: 'Los Angeles',
      latitude: 34.0522342,
      longitude: -118.2436849,
      country: 'US',
      truckTypes: []
    }
  },
  {
    itineraryId: 11863,
    itineraryName: 'Hamburg - Melbourne',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22654,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22655,
      hubId: 5776,
      hubName: 'Melbourne Port',
      nexusId: 3098,
      nexusName: 'Melbourne',
      latitude: -37.8136276,
      longitude: 144.9630576,
      country: 'AU',
      truckTypes: []
    }
  },
  {
    itineraryId: 11864,
    itineraryName: 'Hamburg - Miami',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22656,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22657,
      hubId: 5781,
      hubName: 'Miami Port',
      nexusId: 3103,
      nexusName: 'Miami',
      latitude: 25.7616798,
      longitude: -80.1917902,
      country: 'US',
      truckTypes: []
    }
  },
  {
    itineraryId: 11865,
    itineraryName: 'Hamburg - New York',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22658,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22659,
      hubId: 5818,
      hubName: 'New York Port',
      nexusId: 3140,
      nexusName: 'New York',
      latitude: 40.7127753,
      longitude: -74.0059728,
      country: 'US',
      truckTypes: []
    }
  },
  {
    itineraryId: 11866,
    itineraryName: 'Hamburg - Nhava Sheva',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22660,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22661,
      hubId: 5819,
      hubName: 'Nhava Sheva Port',
      nexusId: 3141,
      nexusName: 'Nhava Sheva',
      latitude: 18.9499361,
      longitude: 72.9511875,
      country: 'IN',
      truckTypes: []
    }
  },
  {
    itineraryId: 11867,
    itineraryName: 'Hamburg - Singapore',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22662,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22663,
      hubId: 3043,
      hubName: 'Singapore Port',
      nexusId: 609,
      nexusName: 'Singapore',
      latitude: 1.26666667,
      longitude: 103.83333333,
      country: 'SG',
      truckTypes: []
    }
  },
  {
    itineraryId: 11868,
    itineraryName: 'Hamburg - Sydney',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22664,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22665,
      hubId: 5975,
      hubName: 'Sydney Port',
      nexusId: 3295,
      nexusName: 'Sydney',
      latitude: -33.8688197,
      longitude: 151.2092955,
      country: 'AU',
      truckTypes: []
    }
  },
  {
    itineraryId: 11869,
    itineraryName: 'Hamburg - Taichung',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22666,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22667,
      hubId: 5978,
      hubName: 'Taichung Port',
      nexusId: 3298,
      nexusName: 'Taichung',
      latitude: 24.1477358,
      longitude: 120.6736482,
      country: 'TW',
      truckTypes: []
    }
  },
  {
    itineraryId: 11870,
    itineraryName: 'Hamburg - Xingang',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22668,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22669,
      hubId: 6046,
      hubName: 'Xingang Port',
      nexusId: 3366,
      nexusName: 'Xingang',
      latitude: 39.0063718,
      longitude: 117.6852235,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 11871,
    itineraryName: 'Hamburg - Tokyo',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22670,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22671,
      hubId: 5999,
      hubName: 'Tokyo Port',
      nexusId: 3319,
      nexusName: 'Tokyo',
      latitude: 35.6894875,
      longitude: 139.6917064,
      country: 'JP',
      truckTypes: []
    }
  },
  {
    itineraryId: 11872,
    itineraryName: 'Hamburg - Toronto',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22672,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22673,
      hubId: 6003,
      hubName: 'Toronto Port',
      nexusId: 3323,
      nexusName: 'Toronto',
      latitude: 43.653226,
      longitude: -79.3831843,
      country: 'CA',
      truckTypes: []
    }
  },
  {
    itineraryId: 11873,
    itineraryName: 'Hamburg - Veracruz',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22674,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22675,
      hubId: 6020,
      hubName: 'Veracruz Port',
      nexusId: 3340,
      nexusName: 'Veracruz',
      latitude: 19.173773,
      longitude: -96.1342241,
      country: 'MX',
      truckTypes: []
    }
  },
  {
    itineraryId: 11874,
    itineraryName: 'Hamburg - Xiamen',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22676,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22677,
      hubId: 6044,
      hubName: 'Xiamen Port',
      nexusId: 3364,
      nexusName: 'Xiamen',
      latitude: 24.479833,
      longitude: 118.089425,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 11875,
    itineraryName: 'Hamburg - Peking',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22678,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 22679,
      hubId: 8659,
      hubName: 'Peking Port',
      nexusId: 5968,
      nexusName: 'Peking',
      latitude: 39.9063932,
      longitude: 116.3575596,
      country: 'CN',
      truckTypes: []
    }
  },
  {
    itineraryId: 11876,
    itineraryName: 'Bangkok - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22680,
      hubId: 5484,
      hubName: 'Bangkok Port',
      nexusId: 2808,
      nexusName: 'Bangkok',
      latitude: 13.7233786,
      longitude: 100.7838827,
      country: 'TH',
      truckTypes: []
    },
    destination: {
      stopId: 22681,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11877,
    itineraryName: 'Beijing - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22682,
      hubId: 5491,
      hubName: 'Beijing Port',
      nexusId: 2815,
      nexusName: 'Beijing',
      latitude: 39.9041999,
      longitude: 116.4073963,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 22683,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11878,
    itineraryName: 'Busan - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22684,
      hubId: 5521,
      hubName: 'Busan Port',
      nexusId: 2845,
      nexusName: 'Busan',
      latitude: 35.1795543,
      longitude: 129.0756416,
      country: 'KR',
      truckTypes: []
    },
    destination: {
      stopId: 22685,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11879,
    itineraryName: 'Chennai - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22686,
      hubId: 5552,
      hubName: 'Chennai Port',
      nexusId: 2876,
      nexusName: 'Chennai',
      latitude: 13.0826802,
      longitude: 80.2707184,
      country: 'IN',
      truckTypes: []
    },
    destination: {
      stopId: 22687,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11880,
    itineraryName: 'Dubai - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22688,
      hubId: 5600,
      hubName: 'Dubai Port',
      nexusId: 2923,
      nexusName: 'Dubai',
      latitude: 25.2048493,
      longitude: 55.2707828,
      country: 'AE',
      truckTypes: []
    },
    destination: {
      stopId: 22689,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11881,
    itineraryName: 'Ho Chi Minh - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22690,
      hubId: 5656,
      hubName: 'Ho Chi Minh Port',
      nexusId: 2978,
      nexusName: 'Ho Chi Minh',
      latitude: 10.8230989,
      longitude: 106.6296638,
      country: 'VN',
      truckTypes: []
    },
    destination: {
      stopId: 22691,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11882,
    itineraryName: 'Hong Kong - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22692,
      hubId: 3042,
      hubName: 'Hong Kong Port',
      nexusId: 606,
      nexusName: 'Hong Kong',
      latitude: 22.316265,
      longitude: 113.939724,
      country: 'HK',
      truckTypes: []
    },
    destination: {
      stopId: 22693,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11883,
    itineraryName: 'Jakarta - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22694,
      hubId: 5679,
      hubName: 'Jakarta Port',
      nexusId: 3001,
      nexusName: 'Jakarta',
      latitude: -6.17511,
      longitude: 106.8650395,
      country: 'ID',
      truckTypes: []
    },
    destination: {
      stopId: 22695,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11884,
    itineraryName: 'Jeddah - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22696,
      hubId: 5682,
      hubName: 'Jeddah Port',
      nexusId: 3004,
      nexusName: 'Jeddah',
      latitude: 21.485811,
      longitude: 39.1925048,
      country: 'SA',
      truckTypes: []
    },
    destination: {
      stopId: 22697,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11885,
    itineraryName: 'Kaohsiung - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22698,
      hubId: 5691,
      hubName: 'Kaohsiung Port',
      nexusId: 3013,
      nexusName: 'Kaohsiung',
      latitude: 22.6272784,
      longitude: 120.3014353,
      country: 'TW',
      truckTypes: []
    },
    destination: {
      stopId: 22699,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11886,
    itineraryName: 'Keelung - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22700,
      hubId: 5694,
      hubName: 'Keelung Port',
      nexusId: 3016,
      nexusName: 'Keelung',
      latitude: 23.69781,
      longitude: 120.960515,
      country: 'TW',
      truckTypes: []
    },
    destination: {
      stopId: 22701,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11887,
    itineraryName: 'Los Angeles - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22702,
      hubId: 5745,
      hubName: 'Los Angeles Port',
      nexusId: 3067,
      nexusName: 'Los Angeles',
      latitude: 34.0522342,
      longitude: -118.2436849,
      country: 'US',
      truckTypes: []
    },
    destination: {
      stopId: 22703,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11888,
    itineraryName: 'Melbourne - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22704,
      hubId: 5776,
      hubName: 'Melbourne Port',
      nexusId: 3098,
      nexusName: 'Melbourne',
      latitude: -37.8136276,
      longitude: 144.9630576,
      country: 'AU',
      truckTypes: []
    },
    destination: {
      stopId: 22705,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11889,
    itineraryName: 'Miami - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22706,
      hubId: 5781,
      hubName: 'Miami Port',
      nexusId: 3103,
      nexusName: 'Miami',
      latitude: 25.7616798,
      longitude: -80.1917902,
      country: 'US',
      truckTypes: []
    },
    destination: {
      stopId: 22707,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11890,
    itineraryName: 'New York - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22708,
      hubId: 5818,
      hubName: 'New York Port',
      nexusId: 3140,
      nexusName: 'New York',
      latitude: 40.7127753,
      longitude: -74.0059728,
      country: 'US',
      truckTypes: []
    },
    destination: {
      stopId: 22709,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11891,
    itineraryName: 'Nhava Sheva - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22710,
      hubId: 5819,
      hubName: 'Nhava Sheva Port',
      nexusId: 3141,
      nexusName: 'Nhava Sheva',
      latitude: 18.9499361,
      longitude: 72.9511875,
      country: 'IN',
      truckTypes: []
    },
    destination: {
      stopId: 22711,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11892,
    itineraryName: 'Singapore - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22712,
      hubId: 3043,
      hubName: 'Singapore Port',
      nexusId: 609,
      nexusName: 'Singapore',
      latitude: 1.26666667,
      longitude: 103.83333333,
      country: 'SG',
      truckTypes: []
    },
    destination: {
      stopId: 22713,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11893,
    itineraryName: 'Sydney - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22714,
      hubId: 5975,
      hubName: 'Sydney Port',
      nexusId: 3295,
      nexusName: 'Sydney',
      latitude: -33.8688197,
      longitude: 151.2092955,
      country: 'AU',
      truckTypes: []
    },
    destination: {
      stopId: 22715,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11894,
    itineraryName: 'Taichung - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22716,
      hubId: 5978,
      hubName: 'Taichung Port',
      nexusId: 3298,
      nexusName: 'Taichung',
      latitude: 24.1477358,
      longitude: 120.6736482,
      country: 'TW',
      truckTypes: []
    },
    destination: {
      stopId: 22717,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11895,
    itineraryName: 'Xingang - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22718,
      hubId: 6046,
      hubName: 'Xingang Port',
      nexusId: 3366,
      nexusName: 'Xingang',
      latitude: 39.0063718,
      longitude: 117.6852235,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 22719,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11896,
    itineraryName: 'Tokyo - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22720,
      hubId: 5999,
      hubName: 'Tokyo Port',
      nexusId: 3319,
      nexusName: 'Tokyo',
      latitude: 35.6894875,
      longitude: 139.6917064,
      country: 'JP',
      truckTypes: []
    },
    destination: {
      stopId: 22721,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11897,
    itineraryName: 'Toronto - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22722,
      hubId: 6003,
      hubName: 'Toronto Port',
      nexusId: 3323,
      nexusName: 'Toronto',
      latitude: 43.653226,
      longitude: -79.3831843,
      country: 'CA',
      truckTypes: []
    },
    destination: {
      stopId: 22723,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11898,
    itineraryName: 'Veracruz - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22724,
      hubId: 6020,
      hubName: 'Veracruz Port',
      nexusId: 3340,
      nexusName: 'Veracruz',
      latitude: 19.173773,
      longitude: -96.1342241,
      country: 'MX',
      truckTypes: []
    },
    destination: {
      stopId: 22725,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11899,
    itineraryName: 'Xiamen - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22726,
      hubId: 6044,
      hubName: 'Xiamen Port',
      nexusId: 3364,
      nexusName: 'Xiamen',
      latitude: 24.479833,
      longitude: 118.089425,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 22727,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 11900,
    itineraryName: 'Peking - Hamburg',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 22728,
      hubId: 8659,
      hubName: 'Peking Port',
      nexusId: 5968,
      nexusName: 'Peking',
      latitude: 39.9063932,
      longitude: 116.3575596,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 22729,
      hubId: 3041,
      hubName: 'Hamburg Port',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17321,
    itineraryName: 'Hamburg - Shanghai',
    modeOfTransport: 'air',
    origin: {
      stopId: 33566,
      hubId: 12770,
      hubName: 'Hamburg Airport',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: []
    },
    destination: {
      stopId: 33567,
      hubId: 3032,
      hubName: 'Shanghai Airport',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17322,
    itineraryName: 'Shanghai - Hamburg',
    modeOfTransport: 'air',
    origin: {
      stopId: 33568,
      hubId: 3032,
      hubName: 'Shanghai Airport',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 33569,
      hubId: 12770,
      hubName: 'Hamburg Airport',
      nexusId: 608,
      nexusName: 'Hamburg',
      latitude: 53.536975,
      longitude: 9.918213,
      country: 'DE',
      truckTypes: []
    }
  },
  {
    itineraryId: 17488,
    itineraryName: 'Hong Kong - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33900,
      hubId: 3042,
      hubName: 'Hong Kong Port',
      nexusId: 606,
      nexusName: 'Hong Kong',
      latitude: 22.316265,
      longitude: 113.939724,
      country: 'HK',
      truckTypes: []
    },
    destination: {
      stopId: 33901,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17489,
    itineraryName: 'Dalian - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33902,
      hubId: 3026,
      hubName: 'Dalian Port',
      nexusId: 600,
      nexusName: 'Dalian',
      latitude: 38.926974,
      longitude: 121.655672,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33903,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17490,
    itineraryName: 'Tianjin - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33904,
      hubId: 3029,
      hubName: 'Tianjin Port',
      nexusId: 603,
      nexusName: 'Tianjin',
      latitude: 38.993914,
      longitude: 117.721024,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33905,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17492,
    itineraryName: 'Qingdao - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33908,
      hubId: 3027,
      hubName: 'Qingdao Port',
      nexusId: 601,
      nexusName: 'Qingdao',
      latitude: 36.083811,
      longitude: 120.323534,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33909,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17493,
    itineraryName: 'Shanghai - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33910,
      hubId: 3025,
      hubName: 'Shanghai Port',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 33911,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17494,
    itineraryName: 'Ningbo - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33912,
      hubId: 3024,
      hubName: 'Ningbo Port',
      nexusId: 598,
      nexusName: 'Ningbo',
      latitude: 29.929641,
      longitude: 121.84597,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33913,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17499,
    itineraryName: 'Hong Kong - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33922,
      hubId: 3042,
      hubName: 'Hong Kong Port',
      nexusId: 606,
      nexusName: 'Hong Kong',
      latitude: 22.316265,
      longitude: 113.939724,
      country: 'HK',
      truckTypes: []
    },
    destination: {
      stopId: 33923,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17501,
    itineraryName: 'Tianjin - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33926,
      hubId: 3029,
      hubName: 'Tianjin Port',
      nexusId: 603,
      nexusName: 'Tianjin',
      latitude: 38.993914,
      longitude: 117.721024,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33927,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17503,
    itineraryName: 'Qingdao - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33930,
      hubId: 3027,
      hubName: 'Qingdao Port',
      nexusId: 601,
      nexusName: 'Qingdao',
      latitude: 36.083811,
      longitude: 120.323534,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33931,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17504,
    itineraryName: 'Shanghai - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33932,
      hubId: 3025,
      hubName: 'Shanghai Port',
      nexusId: 599,
      nexusName: 'Shanghai',
      latitude: 30.626539,
      longitude: 122.064958,
      country: 'CN',
      truckTypes: [
        'default'
      ]
    },
    destination: {
      stopId: 33933,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17505,
    itineraryName: 'Ningbo - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33934,
      hubId: 3024,
      hubName: 'Ningbo Port',
      nexusId: 598,
      nexusName: 'Ningbo',
      latitude: 29.929641,
      longitude: 121.84597,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33935,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17507,
    itineraryName: 'Xiamen - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33938,
      hubId: 6044,
      hubName: 'Xiamen Port',
      nexusId: 3364,
      nexusName: 'Xiamen',
      latitude: 24.479833,
      longitude: 118.089425,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33939,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17510,
    itineraryName: 'Foshan - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33944,
      hubId: 5612,
      hubName: 'Foshan Port',
      nexusId: 2935,
      nexusName: 'Foshan',
      latitude: 23.021478,
      longitude: 113.121435,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33945,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17511,
    itineraryName: 'Fuzhou - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33946,
      hubId: 5621,
      hubName: 'Fuzhou Port',
      nexusId: 2944,
      nexusName: 'Fuzhou',
      latitude: 26.074478,
      longitude: 119.296482,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33947,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17512,
    itineraryName: 'Guangzhou - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33948,
      hubId: 5633,
      hubName: 'Guangzhou Port',
      nexusId: 2956,
      nexusName: 'Guangzhou',
      latitude: 23.12911,
      longitude: 113.264385,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33949,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17513,
    itineraryName: 'Hangzhou - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33950,
      hubId: 5647,
      hubName: 'Hangzhou Port',
      nexusId: 2969,
      nexusName: 'Hangzhou',
      latitude: 30.274084,
      longitude: 120.15507,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33951,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17514,
    itineraryName: 'Jiangmen - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33952,
      hubId: 5683,
      hubName: 'Jiangmen Port',
      nexusId: 3005,
      nexusName: 'Jiangmen',
      latitude: 22.579117,
      longitude: 113.081508,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33953,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17515,
    itineraryName: 'Shantou - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33954,
      hubId: 5950,
      hubName: 'Shantou Port',
      nexusId: 3271,
      nexusName: 'Shantou',
      latitude: 23.354091,
      longitude: 116.681972,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33955,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17516,
    itineraryName: 'Shenzhen - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33956,
      hubId: 3028,
      hubName: 'Shenzhen Port',
      nexusId: 602,
      nexusName: 'Shenzhen',
      latitude: 22.544083,
      longitude: 113.899893,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33957,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17517,
    itineraryName: 'Shunde - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33958,
      hubId: 5955,
      hubName: 'Shunde Port',
      nexusId: 3276,
      nexusName: 'Shunde',
      latitude: 22.80524,
      longitude: 113.293359,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33959,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17518,
    itineraryName: 'Xiaolan - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33960,
      hubId: 6045,
      hubName: 'Xiaolan Port',
      nexusId: 3365,
      nexusName: 'Xiaolan',
      latitude: 22.672099,
      longitude: 113.250897,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33961,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17519,
    itineraryName: 'Xingang - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33962,
      hubId: 6046,
      hubName: 'Xingang Port',
      nexusId: 3366,
      nexusName: 'Xingang',
      latitude: 39.0063718,
      longitude: 117.6852235,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33963,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17520,
    itineraryName: 'Zhongshan - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33964,
      hubId: 6058,
      hubName: 'Zhongshan Port',
      nexusId: 3378,
      nexusName: 'Zhongshan',
      latitude: 22.517585,
      longitude: 113.39277,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33965,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17521,
    itineraryName: 'Zhuhai - Southampton',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33966,
      hubId: 6059,
      hubName: 'Zhuhai Port',
      nexusId: 3379,
      nexusName: 'Zhuhai',
      latitude: 22.270978,
      longitude: 113.576677,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33967,
      hubId: 5961,
      hubName: 'Southampton Port',
      nexusId: 3282,
      nexusName: 'Southampton',
      latitude: 50.9097004,
      longitude: -1.4043509,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17522,
    itineraryName: 'Fuzhou - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33968,
      hubId: 5621,
      hubName: 'Fuzhou Port',
      nexusId: 2944,
      nexusName: 'Fuzhou',
      latitude: 26.074478,
      longitude: 119.296482,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33969,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17523,
    itineraryName: 'Hangzhou - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33970,
      hubId: 5647,
      hubName: 'Hangzhou Port',
      nexusId: 2969,
      nexusName: 'Hangzhou',
      latitude: 30.274084,
      longitude: 120.15507,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33971,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17524,
    itineraryName: 'Jiangmen - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33972,
      hubId: 5683,
      hubName: 'Jiangmen Port',
      nexusId: 3005,
      nexusName: 'Jiangmen',
      latitude: 22.579117,
      longitude: 113.081508,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33973,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17525,
    itineraryName: 'Shantou - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33974,
      hubId: 5950,
      hubName: 'Shantou Port',
      nexusId: 3271,
      nexusName: 'Shantou',
      latitude: 23.354091,
      longitude: 116.681972,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33975,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17526,
    itineraryName: 'Shenzhen - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33976,
      hubId: 3028,
      hubName: 'Shenzhen Port',
      nexusId: 602,
      nexusName: 'Shenzhen',
      latitude: 22.544083,
      longitude: 113.899893,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33977,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17527,
    itineraryName: 'Shunde - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33978,
      hubId: 5955,
      hubName: 'Shunde Port',
      nexusId: 3276,
      nexusName: 'Shunde',
      latitude: 22.80524,
      longitude: 113.293359,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33979,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17528,
    itineraryName: 'Xiaolan - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33980,
      hubId: 6045,
      hubName: 'Xiaolan Port',
      nexusId: 3365,
      nexusName: 'Xiaolan',
      latitude: 22.672099,
      longitude: 113.250897,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33981,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17529,
    itineraryName: 'Xingang - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33982,
      hubId: 6046,
      hubName: 'Xingang Port',
      nexusId: 3366,
      nexusName: 'Xingang',
      latitude: 39.0063718,
      longitude: 117.6852235,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33983,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17530,
    itineraryName: 'Zhongshan - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33984,
      hubId: 6058,
      hubName: 'Zhongshan Port',
      nexusId: 3378,
      nexusName: 'Zhongshan',
      latitude: 22.517585,
      longitude: 113.39277,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33985,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  },
  {
    itineraryId: 17531,
    itineraryName: 'Zhuhai - Felixstowe',
    modeOfTransport: 'ocean',
    origin: {
      stopId: 33986,
      hubId: 6059,
      hubName: 'Zhuhai Port',
      nexusId: 3379,
      nexusName: 'Zhuhai',
      latitude: 22.270978,
      longitude: 113.576677,
      country: 'CN',
      truckTypes: []
    },
    destination: {
      stopId: 33987,
      hubId: 5609,
      hubName: 'Felixstowe Port',
      nexusId: 2932,
      nexusName: 'Felixstowe',
      latitude: 51.961726,
      longitude: 1.351255,
      country: 'GB',
      truckTypes: [
        'default'
      ]
    }
  }
]

export const lookupTablesForRoutes = {
  originHub: {
    3023: [
      1,
      2,
      4,
      5,
      6,
      7
    ],
    3024: [
      10,
      97,
      102
    ],
    3025: [
      0,
      38,
      96,
      101
    ],
    3026: [
      8,
      93
    ],
    3027: [
      9,
      95,
      100
    ],
    3028: [
      11,
      110,
      120
    ],
    3029: [
      94,
      99
    ],
    3030: [
      28,
      34,
      35,
      36,
      37
    ],
    3031: [
      15,
      16,
      17
    ],
    3032: [
      12,
      13,
      14,
      91
    ],
    3034: [
      18,
      19,
      20
    ],
    3035: [
      21,
      22,
      23
    ],
    3037: [
      3,
      24,
      25,
      26,
      27
    ],
    3038: [
      29,
      30,
      31,
      32,
      33
    ],
    3041: [
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
      48,
      49,
      50,
      51,
      52,
      53,
      54,
      55,
      56,
      57,
      58,
      59,
      60,
      61,
      62,
      63,
      64
    ],
    3042: [
      71,
      92,
      98
    ],
    3043: [
      81
    ],
    5484: [
      65
    ],
    5491: [
      66
    ],
    5521: [
      67
    ],
    5552: [
      68
    ],
    5600: [
      69
    ],
    5612: [
      104
    ],
    5621: [
      105,
      116
    ],
    5633: [
      106
    ],
    5647: [
      107,
      117
    ],
    5656: [
      70
    ],
    5679: [
      72
    ],
    5682: [
      73
    ],
    5683: [
      108,
      118
    ],
    5691: [
      74
    ],
    5694: [
      75
    ],
    5745: [
      76
    ],
    5776: [
      77
    ],
    5781: [
      78
    ],
    5818: [
      79
    ],
    5819: [
      80
    ],
    5950: [
      109,
      119
    ],
    5955: [
      111,
      121
    ],
    5975: [
      82
    ],
    5978: [
      83
    ],
    5999: [
      85
    ],
    6003: [
      86
    ],
    6020: [
      87
    ],
    6044: [
      88,
      103
    ],
    6045: [
      112,
      122
    ],
    6046: [
      84,
      113,
      123
    ],
    6058: [
      114,
      124
    ],
    6059: [
      115,
      125
    ],
    8659: [
      89
    ],
    12770: [
      90
    ]
  },
  destinationHub: {
    3023: [
      0,
      8,
      9,
      10,
      11
    ],
    3024: [
      2
    ],
    3025: [
      1,
      39
    ],
    3026: [
      4
    ],
    3027: [
      5
    ],
    3028: [
      6
    ],
    3029: [
      7
    ],
    3030: [
      12,
      15,
      18,
      21
    ],
    3031: [
      25,
      31,
      35
    ],
    3032: [
      3,
      28,
      29,
      90
    ],
    3034: [
      26,
      32,
      36
    ],
    3035: [
      27,
      33,
      37
    ],
    3037: [
      13,
      16,
      19,
      22
    ],
    3038: [
      14,
      17,
      20,
      23
    ],
    3039: [
      24,
      30,
      34
    ],
    3041: [
      38,
      65,
      66,
      67,
      68,
      69,
      70,
      71,
      72,
      73,
      74,
      75,
      76,
      77,
      78,
      79,
      80,
      81,
      82,
      83,
      84,
      85,
      86,
      87,
      88,
      89
    ],
    3042: [
      46
    ],
    3043: [
      56
    ],
    5484: [
      40
    ],
    5491: [
      41
    ],
    5521: [
      42
    ],
    5552: [
      43
    ],
    5600: [
      44
    ],
    5609: [
      98,
      99,
      100,
      101,
      102,
      103,
      116,
      117,
      118,
      119,
      120,
      121,
      122,
      123,
      124,
      125
    ],
    5656: [
      45
    ],
    5679: [
      47
    ],
    5682: [
      48
    ],
    5691: [
      49
    ],
    5694: [
      50
    ],
    5745: [
      51
    ],
    5776: [
      52
    ],
    5781: [
      53
    ],
    5818: [
      54
    ],
    5819: [
      55
    ],
    5961: [
      92,
      93,
      94,
      95,
      96,
      97,
      104,
      105,
      106,
      107,
      108,
      109,
      110,
      111,
      112,
      113,
      114,
      115
    ],
    5975: [
      57
    ],
    5978: [
      58
    ],
    5999: [
      60
    ],
    6003: [
      61
    ],
    6020: [
      62
    ],
    6044: [
      63
    ],
    6046: [
      59
    ],
    8659: [
      64
    ],
    12770: [
      91
    ]
  },
  originNexus: {
    597: [
      1,
      2,
      4,
      5,
      6,
      7,
      28,
      34,
      35,
      36,
      37
    ],
    598: [
      10,
      15,
      16,
      17,
      97,
      102
    ],
    599: [
      0,
      12,
      13,
      14,
      38,
      91,
      96,
      101
    ],
    600: [
      8,
      93
    ],
    601: [
      9,
      18,
      19,
      20,
      95,
      100
    ],
    602: [
      11,
      21,
      22,
      23,
      110,
      120
    ],
    603: [
      94,
      99
    ],
    604: [
      3,
      24,
      25,
      26,
      27
    ],
    605: [
      29,
      30,
      31,
      32,
      33
    ],
    606: [
      71,
      92,
      98
    ],
    608: [
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
      48,
      49,
      50,
      51,
      52,
      53,
      54,
      55,
      56,
      57,
      58,
      59,
      60,
      61,
      62,
      63,
      64,
      90
    ],
    609: [
      81
    ],
    2808: [
      65
    ],
    2815: [
      66
    ],
    2845: [
      67
    ],
    2876: [
      68
    ],
    2923: [
      69
    ],
    2935: [
      104
    ],
    2944: [
      105,
      116
    ],
    2956: [
      106
    ],
    2969: [
      107,
      117
    ],
    2978: [
      70
    ],
    3001: [
      72
    ],
    3004: [
      73
    ],
    3005: [
      108,
      118
    ],
    3013: [
      74
    ],
    3016: [
      75
    ],
    3067: [
      76
    ],
    3098: [
      77
    ],
    3103: [
      78
    ],
    3140: [
      79
    ],
    3141: [
      80
    ],
    3271: [
      109,
      119
    ],
    3276: [
      111,
      121
    ],
    3295: [
      82
    ],
    3298: [
      83
    ],
    3319: [
      85
    ],
    3323: [
      86
    ],
    3340: [
      87
    ],
    3364: [
      88,
      103
    ],
    3365: [
      112,
      122
    ],
    3366: [
      84,
      113,
      123
    ],
    3378: [
      114,
      124
    ],
    3379: [
      115,
      125
    ],
    5968: [
      89
    ]
  },
  destinationNexus: {
    597: [
      0,
      8,
      9,
      10,
      11,
      12,
      15,
      18,
      21
    ],
    598: [
      2,
      25,
      31,
      35
    ],
    599: [
      1,
      3,
      28,
      29,
      39,
      90
    ],
    600: [
      4
    ],
    601: [
      5,
      26,
      32,
      36
    ],
    602: [
      6,
      27,
      33,
      37
    ],
    603: [
      7
    ],
    604: [
      13,
      16,
      19,
      22
    ],
    605: [
      14,
      17,
      20,
      23
    ],
    606: [
      24,
      30,
      34,
      46
    ],
    608: [
      38,
      65,
      66,
      67,
      68,
      69,
      70,
      71,
      72,
      73,
      74,
      75,
      76,
      77,
      78,
      79,
      80,
      81,
      82,
      83,
      84,
      85,
      86,
      87,
      88,
      89,
      91
    ],
    609: [
      56
    ],
    2808: [
      40
    ],
    2815: [
      41
    ],
    2845: [
      42
    ],
    2876: [
      43
    ],
    2923: [
      44
    ],
    2932: [
      98,
      99,
      100,
      101,
      102,
      103,
      116,
      117,
      118,
      119,
      120,
      121,
      122,
      123,
      124,
      125
    ],
    2978: [
      45
    ],
    3001: [
      47
    ],
    3004: [
      48
    ],
    3013: [
      49
    ],
    3016: [
      50
    ],
    3067: [
      51
    ],
    3098: [
      52
    ],
    3103: [
      53
    ],
    3140: [
      54
    ],
    3141: [
      55
    ],
    3282: [
      92,
      93,
      94,
      95,
      96,
      97,
      104,
      105,
      106,
      107,
      108,
      109,
      110,
      111,
      112,
      113,
      114,
      115
    ],
    3295: [
      57
    ],
    3298: [
      58
    ],
    3319: [
      60
    ],
    3323: [
      61
    ],
    3340: [
      62
    ],
    3364: [
      63
    ],
    3366: [
      59
    ],
    5968: [
      64
    ]
  }
}

export const routeSelectionStateMock = () => ({
  app: { tenant: { ...tenant, scope } },
  bookingData: {
    response: {
      stage1: {
        lookupTablesForRoutes: {
          originHub: { 18513: [1] },
          destinationHub: { 18513: [13] },
          originNexus: {},
          destinationNexus: {},
          tenantVehicleId: { '': [0] }
        },
        routes: [
          {
            itineraryId: 23879,
            itineraryName: 'Ningbo - Ipswich',
            transshipment: null,
            modeOfTransport: 'ocean',
            cargoClasses: ['fcl_20', 'lcl', 'fcl_40', 'fcl_40_hq'],
            origin: {
              stopId: 50385,
              hubId: 18516,
              hubName: 'Ningbo Port',
              nexusId: 12794,
              nexusName: 'Ningbo',
              latitude: 29.826602,
              longitude: 121.462084,
              country: 'CN',
              locode: 'CNNBO',
              truckTypes: ['default']
            },
            destination: {
              stopId: 50386,
              hubId: 18518,
              hubName: 'Ipswich Port',
              nexusId: 12796,
              nexusName: 'Ipswich',
              latitude: 52.05,
              longitude: 1.14,
              country: 'GB',
              locode: 'FEO1',
              truckTypes: ['default']
            }
          }
        ]
      }
    }
  },
  bookingProcess: {
    shipment: {
      aggregatedCargo: false,
      onCarriage: false,
      preCarriage: false,
      origin: {},
      destination: {},
      cargoUnits: [
        {
          payloadInKg: 0,
          totalVolume: 0,
          totalWeight: 0,
          width: 0,
          length: 0,
          height: 0,
          quantity: 1,
          cargoItemTypeId: '',
          dangerousGoods: false,
          stackable: true
        }
      ],
      trucking: {
        preCarriage: { truckType: '' },
        onCarriage: { truckType: '' }
      },
      loadType: 'cargo_item',
      direction: 'export',
      id: 48443
    },
    ShipmentDetails: {
      availableMots: ['ocean', 'air'],
      availableRoutes: [
        {
          itineraryId: 23879,
          itineraryName: 'Ningbo - Ipswich',
          transshipment: null,
          modeOfTransport: 'ocean',
          cargoClasses: ['fcl_20', 'lcl', 'fcl_40', 'fcl_40_hq'],
          origin: {
            stopId: 50385,
            hubId: 18516,
            hubName: 'Ningbo Port',
            nexusId: 12794,
            nexusName: 'Ningbo',
            latitude: 29.826602,
            longitude: 121.462084,
            country: 'CN',
            locode: 'CNNBO',
            truckTypes: []
          },
          destination: {
            stopId: 50386,
            hubId: 18518,
            hubName: 'Ipswich Port',
            nexusId: 12796,
            nexusName: 'Ipswich',
            latitude: 52.05,
            longitude: 1.14,
            country: 'GB',
            locode: 'FEO1',
            truckTypes: ['default']
          }
        }
      ]
    }
  }
})
