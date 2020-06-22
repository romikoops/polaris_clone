import { getTotalShipmentErrors } from './index'

const emptyMaxDimension = {
  width: '0.0',
  length: '0.0',
  height: '0.0',
  payloadInKg: '0.0',
  chargeableWeight: '0.0',
  volume: '0.0'
}

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

describe('getTotalShipmentErrors', () => {
  it('no errors', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: {
        general: emptyMaxDimension,
        air: {
          width: '0.0',
          length: '0.0',
          height: '0.0',
          payloadInKg: '1000.0',
          chargeableWeight: '1000.0',
          volume: '1000.0'
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
      payloadInKg: {},
      volume: {}
    })
  })

  it('warnings', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: {
        ocean: emptyMaxDimension,
        air: {
          ...emptyMaxDimension,
          payloadInKg: '1000.0',
          chargeableWeight: '1000.0',
          volume: '0.1'
        }
      },
      cargoItems,
      hasTrucking: false
    })

    expect(result.chargeableWeight).toEqual({
      errors: [{ modeOfTransport: 'air', max: 1000, actual: 1200 }], type: 'warning'
    })

    expect(result.payloadInKg).toEqual({
      errors: [{ modeOfTransport: 'air', max: 1000, actual: 1200 }], type: 'warning'
    })

    expect(result.volume).toEqual({
      errors: [{ modeOfTransport: 'air', max: 0.1, actual: 1 }], type: 'warning'
    })
  })

  it('payloadInKg with one error', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: {
        general: emptyMaxDimension,
        air: { ...emptyMaxDimension, payloadInKg: '1000.0' }
      },
      cargoItems,
      hasTrucking: false
    })

    expect(result.payloadInKg).toEqual({
      errors: [{ modeOfTransport: 'air', max: 1000, actual: 1200 }], type: 'warning'
    })
  })

  it('payloadInKg all mots with error', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: {
        general: { ...emptyMaxDimension, payloadInKg: '10.0' }
      },
      cargoItems,
      hasTrucking: false
    })

    expect(result.payloadInKg).toEqual({
      errors: [{
        modesOfTransport: ['air', 'ocean'],
        max: 10,
        actual: 1200,
        allMotsExceeded: true
      }],
      type: 'error'
    })
  })

  it('payloadInKg all mots with error and trucking', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: {
        general: { ...emptyMaxDimension, payloadInKg: '10.0' },
        truckCarriage: { ...emptyMaxDimension, payloadInKg: '10.0' }
      },
      cargoItems,
      hasTrucking: true
    })

    expect(result.payloadInKg).toEqual({
      errors: [{
        modesOfTransport: ['truckCarriage', 'air', 'ocean'],
        max: 10,
        actual: 1200,
        allMotsExceeded: true
      }],
      type: 'error'
    })
  })

  it('volume with one error', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: {
        general: emptyMaxDimension,
        air: { ...emptyMaxDimension, volume: '0.1' }
      },
      cargoItems,
      hasTrucking: false
    })

    expect(result.volume).toEqual({
      errors: [{ modeOfTransport: 'air', max: 0.1, actual: 1 }], type: 'warning'
    })
  })

  it('volume all mots with error', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: {
        general: { ...emptyMaxDimension, volume: '0.1' }
      },
      cargoItems,
      hasTrucking: false
    })

    expect(result.volume).toEqual({
      errors: [{ modesOfTransport: ['air', 'ocean'], max: 0.1, actual: 1, allMotsExceeded: true }],
      type: 'error'
    })
  })

  it('volume all mots with error and trucking', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: { general: { ...emptyMaxDimension, volume: '0.1' } },
      cargoItems,
      hasTrucking: true
    })

    expect(result.volume).toEqual({
      errors: [{
        modesOfTransport: ['truckCarriage', 'air', 'ocean'],
        max: 0.1,
        actual: 1,
        allMotsExceeded: true
      }],
      type: 'error'
    })
  })

  it('chargeableWeight with one error', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: {
        general: emptyMaxDimension,
        air: { ...emptyMaxDimension, chargeableWeight: '500' }
      },
      cargoItems,
      hasTrucking: false
    })

    expect(result.chargeableWeight).toEqual({
      errors: [{ modeOfTransport: 'air', max: 500, actual: 1200 }], type: 'warning'
    })
  })

  it('chargeableWeight all mots with error', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: { general: { ...emptyMaxDimension, chargeableWeight: '10.0' } },
      cargoItems,
      hasTrucking: false
    })

    expect(result.chargeableWeight).toEqual({
      errors: [{ modesOfTransport: ['air', 'ocean'], max: 10, actual: 1200, allMotsExceeded: true }],
      type: 'error'
    })
  })

  it('chargeableWeight all mots with error and trucking', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: { general: { ...emptyMaxDimension, chargeableWeight: '0.1' } },
      cargoItems,
      hasTrucking: true
    })

    expect(result.chargeableWeight).toEqual({
      errors: [{
        modesOfTransport: ['truckCarriage', 'air', 'ocean'],
        max: 0.1,
        actual: 1200,
        allMotsExceeded: true
      }],
      type: 'error'
    })
  })

  it('handles one missing maxDimensionsBundles', () => {
    const result = getTotalShipmentErrors({
      modesOfTransport: ['air', 'ocean'],
      maxDimensions: {
        air: { payloadInKg: '1000.0' }
      },
      cargoItems,
      hasTrucking: false
    })

    expect(result.chargeableWeight).toEqual({})
    expect(result.payloadInKg).not.toEqual({})
    expect(result.volume).toEqual({})
  })
})
