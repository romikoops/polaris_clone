import { maxBy } from 'lodash'
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

  payloadInKg = getPayloadInKgErrors(
    getFilteredMaxDimensions(['truckCarriage', 'general', ...modesOfTransport], maxDimensions),
    'payloadInKg',
    cargoItems.reduce((sum, cargoItem) => sum + (cargoItem.payloadInKg * cargoItem.quantity), 0),
    ['truckCarriage']
  )

  const chargeableWeightValues = {}

  modesOfTransport.forEach((modeOfTransport) => {
    chargeableWeightValues[modeOfTransport] = 0

    cargoItems.forEach((cargoItem) => {
      chargeableWeightValues[modeOfTransport] += +chargeableWeightValue(cargoItem, modeOfTransport)
    })
  })

  return {
    payloadInKg,
    chargeableWeight: getChargableWeightErrors(
      getFilteredMaxDimensions(['general', ...modesOfTransport], maxDimensions),
      'chargeableWeight',
      chargeableWeightValues,
      modesOfTransport
    )
  }
}

export function getPayloadInKgErrors (maxDimensions, name, value, modesOfTransport) {
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

export function getChargableWeightErrors (maxDimensions, name, values, modesOfTransport) {
  let errors = []
  Object.entries(values).forEach(([modeOfTransport, value]) => {
    const maxDimension = maxDimensions[modeOfTransport] || maxDimensions.general

    if (!maxDimension || !maxDimension[name]) { return }

    const actual = Math.abs(value)
    const max = Math.abs(maxDimension[name])

    if (max > 0 && actual > max) {
      errors.push({ modeOfTransport, max, actual })
    }
  })

  if (errors.length === 0) return {}

  let type = 'warning'
  if (errors.length >= modesOfTransport.length) {
    const { max, actual } = maxBy(errors, 'max')
    type = 'error'

    errors = [{ modesOfTransport, max, actual, allMotsExceeded: true }]
  }

  return { errors, type }
}
