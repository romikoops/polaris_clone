import { numberSpacing } from '.'

export const effectiveKgPerCubicMeter = {
  air: 167,
  rail: 550,
  truck: 333,
  ocean: 1000,
  truckCarriage: 333
}
export function singleItemChargeableObject (cargoItem, mot, t, scope) {
  if (!cargoItem) return undefined
  const volumeVal = +singleVolume(cargoItem)
  const weightVal = +cargoItem.payload_in_kg
  const showVolume = volumeVal > weightVal
  const chargeableWeightVal = Math.max(
    volumeVal * effectiveKgPerCubicMeter[mot],
    weightVal
  )
  const chargeableVolumeVal = chargeableWeightVal / 1000

  return chargeableObject(chargeableVolumeVal, chargeableWeightVal, showVolume, t, scope, cargoItem.quantity)
}
export function multiItemChargeableObject (cargoItems, mot, t, scope) {
  if (!cargoItems) return undefined
  const volumeVal = cargoItems.reduce((product, item) => (
    product + +volume(item)
  ), 0)
  const weightVal = cargoItems.reduce((product, item) => (
    product + +item.payload_in_kg * item.quantity
  ), 0)
  const showVolume = volumeVal > weightVal
  const chargeableWeightVal = Math.max(
    volumeVal * effectiveKgPerCubicMeter[mot],
    weightVal
  )
  const chargeableVolumeVal = chargeableWeightVal / 1000

  return chargeableObject(chargeableVolumeVal, chargeableWeightVal, showVolume, t, scope, 1)
}
export function fixedWeightChargeableString (cargoItems, fixedWeight, t, scope) {
  if (!cargoItems) return undefined
  const volumeVal = cargoItems.reduce((product, item) => (
    product + +volume(item)
  ), 0)
  const weightVal = cargoItems.reduce((product, item) => (
    product + +item.payload_in_kg * item.quantity
  ), 0)
  const showVolume = volumeVal > (weightVal / 1000)
  const chargeableWeightVal = numberSpacing(fixedWeight, 2)
  const chargeableVolumeVal = numberSpacing(fixedWeight / 1000, 3)

  return chargeableString(chargeableVolumeVal, chargeableWeightVal, showVolume, t, scope)
}
export function chargeableObject (volumeVal, weightVal, showVolume, t, scope, quantity = 1) {
  switch (scope.chargeable_weight_view) {
    case 'weight':

      return {
        value: `<span>${numberSpacing(weightVal, 2)}</span> kg`,
        title: t('cargo:chargeableWeight'),
        total_value: `<span>${numberSpacing(weightVal * quantity, 2)}</span> kg`,
        total_title: t('cargo:totalChargeableWeight')
      }
    case 'volume':

      return {
        value: `<span>${numberSpacing(volumeVal, 3)}</span> m<sup>3</sup>`,
        title: t('cargo:chargeableVolume'),
        total_value: `<span>${numberSpacing(volumeVal * quantity, 3)}</span> m<sup>3</sup>`,
        total_title: t('cargo:totalChargeableVolume')
      }
    case 'both':

      return {
        value: `<span>${numberSpacing(volumeVal, 3)}</span> t | m<sup>3</sup>`,
        title: t('cargo:chargeableWeightVol'),
        total_value: `<span>${numberSpacing(volumeVal * quantity, 3)}</span> t | m<sup>3</sup>`,
        total_title: t('cargo:totalChargeableWeightVol')
      }
    case 'dynamic':

      return showVolume ? {
        value: `<span>${numberSpacing(volumeVal, 3)}</span> m<sup>3</sup>`,
        title: t('cargo:chargebleVolume'),
        total_value: `<span>${numberSpacing(volumeVal * quantity, 3)}</span> m<sup>3</sup>`,
        total_title: t('cargo:totalChargeableVolume')
      } : {
        value: `<span>${numberSpacing(weightVal, 2)}</span> kg`,
        title: t('cargo:chargeableWeight'),
        total_value: `<span>${numberSpacing(weightVal * quantity, 2)}</span> kg`,
        total_title: t('cargo:totalChargeableWeight')
      }
    default:
      return {
        value: `<span>${numberSpacing(volumeVal, 3)}</span> t | m<sup>3</sup>`,
        title: t('cargo:chargeableWeightVol'),
        total_value: `<span>${numberSpacing(volumeVal * quantity, 3)}</span> t | m<sup>3</sup>`,
        total_title: t('cargo:totalChargeableWeightVol')
      }
  }
}
export function chargeableString (volumeVal, weightVal, showVolume, t, scope) {
  switch (scope.chargeable_weight_view) {
    case 'weight':

      return t('cargo:chargeableWeightWithValue', { value: weightVal })
    case 'volume':

      return t('cargo:chargeableVolumeWithValue', { value: volumeVal })
    case 'both':

      return t('cargo:chargeableWeightVolWithValue', { value: volumeVal })
    case 'dynamic':

      if (showVolume) {
        return t('cargo:chargeableVolumeWithValue', { value: volumeVal })
      }

      return t('cargo:chargeableWeightWithValue', { value: weightVal })

    default:
      return t('cargo:chargeableWeightVolWithValue', { value: volumeVal })
  }
}
export function chargeableWeightValue (cargoItem, mot) {
  if (!cargoItem) return undefined
  const item = cargoItem.width ? convertCargoItemAttributes(cargoItem) : cargoItem

  return Math.max(
    +volume(item) * effectiveKgPerCubicMeter[mot],
    +item.payload_in_kg * item.quantity
  )

}

export function convertCargoItemAttributes (cargoItem) {
  return {
    width: cargoItem.width,
    length: cargoItem.length,
    height: cargoItem.height,
    payload_in_kg: cargoItem.payloadInKg,
    quantity: cargoItem.quantity
  }
}

export function chargeableWeight (cargoItem, mot) {
  if (!cargoItem) return undefined

  return numberSpacing(chargeableWeightValue(cargoItem, mot), 2)
}
export function chargeableWeightTon (cargoItem, mot) {
  if (!cargoItem) return undefined

  return numberSpacing(chargeableWeightValue(cargoItem, mot) / 1000, 3)
}

export function chargeableVolume (cargoItem, mot) {
  if (!cargoItem) return undefined

  const finalValue = Math.max(
    +volume(cargoItem),
    +cargoItem.payload_in_kg * cargoItem.quantity / effectiveKgPerCubicMeter[mot]
  )

  return numberSpacing(finalValue, 3)
}

export function volume (cargoItem) {
  if (!cargoItem) return undefined

  const unitVolume =
    +cargoItem.width * +cargoItem.length * +cargoItem.height / 100 ** 3

  return (unitVolume * cargoItem.quantity)
}
export function singleVolume (cargoItem) {
  if (!cargoItem) return undefined

  const unitVolume =
    +cargoItem.width * +cargoItem.length * +cargoItem.height / 100 ** 3

  return unitVolume
}

export function weight (cargoItem) {
  if (!cargoItem) return undefined

  return numberSpacing((cargoItem.payload_in_kg * cargoItem.quantity), 1)
}

export function weightDynamicScale (cargoItem, scale, decimals = 1) {
  if (!cargoItem) return undefined
  if (scale === 'kg') {
    return numberSpacing((cargoItem.payload_in_kg * cargoItem.quantity), decimals)
  }

  return numberSpacing(((cargoItem.payload_in_kg * cargoItem.quantity) / 1000), decimals)
}

export function rawWeight (cargoItem) {
  if (!cargoItem) return undefined

  return cargoItem.payload_in_kg * cargoItem.quantity
}
