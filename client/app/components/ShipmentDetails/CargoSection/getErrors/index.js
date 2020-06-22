import { maxBy } from 'lodash'
import { chargeableWeightValue } from '../../../../helpers'
import { volume } from '../../../../helpers/cargoItemTools'

function getFilteredMaxDimensions (modesOfTransport, maxDimensions) {
  return modesOfTransport.reduce((obj, mot) => (
    maxDimensions[mot] ? { ...obj, [mot]: maxDimensions[mot] } : obj
  ), { general: maxDimensions.general })
}

export function getTotalShipmentErrors ({
  modesOfTransport, maxDimensions, cargoItems, hasTrucking
}) {
  const updatedMots = hasTrucking ? ['truckCarriage', ...modesOfTransport] : [...modesOfTransport]
  const filteredMaxDimensions = getFilteredMaxDimensions(updatedMots, maxDimensions)

  const aggregatedPayload = cargoItems.reduce((sum, cargoItem) => sum + (cargoItem.payloadInKg * cargoItem.quantity), 0)
  const payloadInKg = buildErrors(
    filteredMaxDimensions,
    updatedMots,
    'payloadInKg',
    aggregatedPayload
  )

  const aggregatedVolume = cargoItems.reduce((sum, cargoItem) => sum + volume(cargoItem), 0)
  const volumeValue = buildErrors(filteredMaxDimensions, updatedMots, 'volume', aggregatedVolume)

  const chargeableWeightByMOT = mapChargeableWeightByMOT(updatedMots, cargoItems)
  const chargeableWeight = buildChargeableWeightErrors(
    filteredMaxDimensions,
    updatedMots,
    chargeableWeightByMOT
  )

  return {
    chargeableWeight,
    payloadInKg,
    volume: volumeValue
  }
}

function prepareErrorsResponse (errors, modesOfTransport) {
  let updatedErrors = errors.filter((error) => !!error)
  if (!updatedErrors.length) return {}

  let type = 'warning'
  const { max, actual } = maxBy(errors, 'max')

  if (updatedErrors.length >= modesOfTransport.length) {
    type = 'error'
    updatedErrors = [{ modesOfTransport, max, actual, allMotsExceeded: true }]
  }

  if (isTruckCarriageViolated(updatedErrors)) {
    type = 'error'
    updatedErrors = [{ modesOfTransport, max, actual, allMotsExceeded: true }]
  }

  return { errors: updatedErrors, type }
}

export function buildError (maxDimensions, modeOfTransport, dimension, actual) {
  const maxDimension = maxDimensions[modeOfTransport] || maxDimensions.general
  if (modeOfTransport === 'general' || !maxDimension || !maxDimension[dimension]) { return null }

  const max = Math.abs(maxDimension[dimension])
  if (max === 0 || actual <= max) { return null }

  return { modeOfTransport, max, actual }
}

export function buildErrors (maxDimensions, modesOfTransport, dimension, value) {
  return prepareErrorsResponse(
    modesOfTransport.map((modeOfTransport) => buildError(maxDimensions, modeOfTransport, dimension, value)),
    modesOfTransport
  )
}

function buildChargeableWeightErrors (maxDimensions, modesOfTransport, chargeableWeightByMOT) {
  const entries = Object.entries(chargeableWeightByMOT)

  return prepareErrorsResponse(
    entries.map(([modeOfTransport, value]) => buildError(maxDimensions, modeOfTransport, 'chargeableWeight', value)),
    modesOfTransport
  )
}

function aggregateChargeableWeight (modeOfTransport) {
  return (sum, cargoItem) => sum + Math.abs(chargeableWeightValue(cargoItem, modeOfTransport) || 0)
}

function mapChargeableWeightByMOT (modesOfTransport, cargoItems) {
  const chargeableWeightByMOT = {}

  modesOfTransport.forEach((modeOfTransport) => {
    chargeableWeightByMOT[modeOfTransport] = cargoItems.reduce(aggregateChargeableWeight(modeOfTransport), 0)
  })

  return chargeableWeightByMOT
}

function isTruckCarriageViolated (errors) {
  return errors.some((error) => error.modeOfTransport === 'truckCarriage' ||
    (error.modesOfTransport && error.modesOfTransport.includes('truckCarriage')))
}
