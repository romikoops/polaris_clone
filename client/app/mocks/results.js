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
