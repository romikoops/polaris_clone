import { numberSpacing } from '.'

export const effectiveKgPerCubicMeter = {
  air: 167,
  rail: 550,
  truck: 333,
  ocean: 1000
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
  const chargeableWeightVal = fixedWeight
  const chargeableVolumeVal = chargeableWeightVal / 1000

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
export function chargeableWeight (cargoItem, mot) {
  if (!cargoItem) return undefined

  const finalValue = Math.max(
    +volume(cargoItem) * effectiveKgPerCubicMeter[mot],
    +cargoItem.payload_in_kg * cargoItem.quantity
  )

  return numberSpacing(finalValue, 2)
}
export function chargeableWeightTon (cargoItem, mot) {
  if (!cargoItem) return undefined

  const finalValue = Math.max(
    +volume(cargoItem) * effectiveKgPerCubicMeter[mot],
    +cargoItem.payload_in_kg * cargoItem.quantity
  )

  return numberSpacing(finalValue / 1000, 3)
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
    cargoItem.dimension_x * cargoItem.dimension_y * cargoItem.dimension_z / 100 ** 3

  return (unitVolume * cargoItem.quantity)
}
export function singleVolume (cargoItem) {
  if (!cargoItem) return undefined

  const unitVolume =
    cargoItem.dimension_x * cargoItem.dimension_y * cargoItem.dimension_z / 100 ** 3

  return unitVolume
}

export function weight (cargoItem) {
  if (!cargoItem) return undefined

  return numberSpacing((cargoItem.payload_in_kg * cargoItem.quantity), 1)
}

export function rawWeight (cargoItem) {
  if (!cargoItem) return undefined

  return cargoItem.payload_in_kg * cargoItem.quantity
}
