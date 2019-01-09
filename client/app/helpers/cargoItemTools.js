import { numberSpacing } from "./"

const effectiveKgPerCubicMeter = {
  air: 167,
  rail: 550,
  truck: 333,
  ocean: 1000
}

export function chargeableWeight (cargoItem, mot) {
  if (!cargoItem) return undefined

  const finalValue = Math.max(
    +volume(cargoItem) * effectiveKgPerCubicMeter[mot],
    +cargoItem.payload_in_kg * cargoItem.quantity
  )

  return numberSpacing(finalValue, 1)
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

export function weight (cargoItem) {
  if (!cargoItem) return undefined

  return numberSpacing((cargoItem.payload_in_kg * cargoItem.quantity), 1)
}
