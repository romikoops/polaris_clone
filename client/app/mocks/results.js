export const firstResult = {
  meta: {
    service_level: 'FOO_SERVICE_LEVEL',
    service_level_count: 1,
    carrier_name: 'FOO_CARRIER_NAME',
    mode_of_transport: 'air',
    origin_hub: {
      name: 'Gothenburg'
    },
    destination_hub: {
      name: 'Shanghai'
    },
    pricing_range_data: {
      fcl_20: {
        BAS: {
          rate: '750.0',
          rate_basis: 'PER_CONTAINER',
          currency: 'USD',
          min: '750.0',
          range: []
        },
        total: {
          value: '750.0',
          currency: 'USD'
        },
        valid_until: '2019-12-31T00:00:00.000Z'
      },
      fcl_40: {
        BAS: {
          rate: '1400.0',
          rate_basis: 'PER_CONTAINER',
          currency: 'USD',
          min: '1400.0',
          range: []
        },
        total: {
          value: '1400.0',
          currency: 'USD'
        },
        valid_until: '2019-12-31T00:00:00.000Z'
      },
      fcl_40_hq: {
        BAS: {
          rate: '1400.0',
          rate_basis: 'PER_CONTAINER',
          currency: 'USD',
          min: '1400.0',
          range: []
        },
        total: {
          value: '1400.0',
          currency: 'USD'
        },
        valid_until: '2019-12-31T00:00:00.000Z'
      }
    }
  },
  quote: {
    total: {
      value: 467
    }
  },
  schedules: [{
    eta: '10-09-2018',
    closing_date: '16-09-2018',
    etd: '15-09-2018'
  }]
}

export const secondResult = {
  meta: { mode_of_transport: 'ocean' },
  quote: {
    total: {
      value: 309
    }
  }
}

export const results = [
  firstResult,
  secondResult
]
