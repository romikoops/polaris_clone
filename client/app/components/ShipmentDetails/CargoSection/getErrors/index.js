import { chargeableWeightValue } from '../../../../helpers'

function getFilteredMaxDimensions (modesOfTransport, maxDimensions) {
  return modesOfTransport.reduce((obj, mot) => (
    maxDimensions[mot] ? { ...obj, [mot]: maxDimensions[mot] } : obj
  ), {})
}

export function getTotalShipmentErrors ({
  modesOfTransport, maxDimensions, cargoItems, hasTrucking
}) {
  let payloadInKg = {}

  if (hasTrucking) {
    payloadInKg = getErrorObj(
      getFilteredMaxDimensions(['truckCarriage', 'general', ...modesOfTransport], maxDimensions),
      'payloadInKg',
      cargoItems.reduce((sum, cargoItem) => sum + (cargoItem.payloadInKg * cargoItem.quantity), 0),
      ['truckCarriage']
    )
  }

  const chargeableWeightValues = {}

  modesOfTransport.forEach((modeOfTransport) => {
    chargeableWeightValues[modeOfTransport] = 0

    cargoItems.forEach((cargoItem) => {
      chargeableWeightValues[modeOfTransport] += +chargeableWeightValue(cargoItem, modeOfTransport)
    })
  })

  return {
    payloadInKg,
    chargeableWeight: getErrorObj(
      getFilteredMaxDimensions(['general', ...modesOfTransport], maxDimensions),
      'chargeableWeight',
      chargeableWeightValues,
      modesOfTransport
    )
  }
}

export function getErrorObj (maxDimensions, name, value, modesOfTransport) {
  const errors = []
  Object.entries(maxDimensions).forEach(([modeOfTransport, constraints]) => {
    const actual = typeof value === 'object' ? +value[modeOfTransport] : +value
    const max = +constraints[name]

    if (max > 0 && actual > max) errors.push({ modeOfTransport, max, actual })
  })

  if (errors.length === 0) return {}

  const type = errors.length < modesOfTransport.length ? 'warning' : 'error'

  return { errors, type }
}
