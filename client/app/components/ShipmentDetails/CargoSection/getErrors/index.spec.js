import { getTotalShipmentErrors } from './index'
const cargoItems = [
  {
    payloadInKg: 1200,
    totalVolume: 0,
    totalWeight: 0,
    width: 100,
    length: 100,
    height: 100,
    quantity: 1,
    cargoItemTypeId: '',
    dangerousGoods: false,
    stackable: true
  }
]
test('no errors', () => {
  const result = getTotalShipmentErrors({
    modesOfTransport: ['air', 'ocean'],
    maxDimensions: {
      general: {
        width: '0.0',
        length: '0.0',
        height: '0.0',
        payloadInKg: '0.0',
        chargeableWeight: '0.0'
      },
      air: {
        width: '0.0',
        length: '0.0',
        height: '0.0',
        payloadInKg: '1000.0',
        chargeableWeight: '1000.0'
      }
    },
    cargoItems: [
      {
        payloadInKg: 500,
        totalVolume: 0,
        totalWeight: 0,
        width: 100,
        length: 100,
        height: 100,
        quantity: 1,
        cargoItemTypeId: '',
        dangerousGoods: false,
        stackable: true
      }
    ],
    hasTrucking: true
  })
  expect(result).toEqual({
    chargeableWeight: {},
    payloadInKg: {}
  })
})

test('warnings', () => {
  const result = getTotalShipmentErrors({
    modesOfTransport: ['air', 'ocean'],
    maxDimensions: {
      general: {
        width: '0.0',
        length: '0.0',
        height: '0.0',
        payloadInKg: '0.0',
        chargeableWeight: '0.0'
      },
      air: {
        width: '0.0',
        length: '0.0',
        height: '0.0',
        payloadInKg: '1000.0',
        chargeableWeight: '1000.0'
      }
    },
    cargoItems,
    hasTrucking: false
  })
  expect(result).toEqual({
    chargeableWeight: {
      errors: [{ modeOfTransport: 'air', max: 1000, actual: 1200 }],
      type: 'warning'
    },
    payloadInKg: {}
  })
})

test('trucking errors', () => {
  const result = getTotalShipmentErrors({
    modesOfTransport: ['air', 'ocean'],
    maxDimensions: {
      general: {
        width: '0.0',
        length: '0.0',
        height: '0.0',
        payloadInKg: '0.0',
        chargeableWeight: '0.0'
      },
      air: {
        width: '0.0',
        length: '0.0',
        height: '0.0',
        payloadInKg: '0.0',
        chargeableWeight: '0.0'
      },
      truckCarriage: {
        width: '0.0',
        length: '0.0',
        height: '0.0',
        payloadInKg: '1000.0',
        chargeableWeight: '1000.0'
      }
    },
    cargoItems,
    hasTrucking: true
  })
  expect(result).toEqual({
    chargeableWeight: {},
    payloadInKg: {
      errors: [{ modeOfTransport: 'truckCarriage', max: 1000, actual: 1200 }],
      type: 'error'
    }
  })
})
test('defaulting to general errors', () => {
  const result = getTotalShipmentErrors({
    modesOfTransport: ['air', 'ocean'],
    maxDimensions: {
      general: {
        width: '0.0',
        length: '0.0',
        height: '0.0',
        payloadInKg: '1000.0',
        chargeableWeight: '0.0'
      }
    },
    cargoItems,
    hasTrucking: true
  })
  expect(result).toEqual({
    chargeableWeight: {},
    payloadInKg: {
      errors: [{ modeOfTransport: 'general', max: 1000, actual: 1200 }],
      type: 'error'
    }
  })
})
test('ocean errors', () => {
  const result = getTotalShipmentErrors({
    modesOfTransport: ['air', 'ocean'],
    maxDimensions: {
      ocean: {
        width: '0.0',
        length: '0.0',
        height: '0.0',
        payloadInKg: '1000.0',
        chargeableWeight: '0.0'
      }
    },
    cargoItems,
    hasTrucking: true
  })
  expect(result).toEqual({
    chargeableWeight: {},
    payloadInKg: {
      errors: [{ modeOfTransport: 'ocean', max: 1000, actual: 1200 }],
      type: 'error'
    }
  })
})
