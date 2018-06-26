export function chargeableWeight (cargoItem, mot) {
  if (!cargoItem) return undefined

  const effectiveKgPerCubicMeter = {
    air: 167,
    rail: 550,
    truck: 333,
    ocean: 1000
  }

  return Math.max(
    +volume(cargoItem) * effectiveKgPerCubicMeter[mot],
    +cargoItem.payload_in_kg * cargoItem.quantity
  ).toFixed(1)
}

export function volume (cargoItem) {
  if (!cargoItem) return undefined

  const unitVolume =
    cargoItem.dimension_x * cargoItem.dimension_y * cargoItem.dimension_z / 100 ** 3

  return (unitVolume * cargoItem.quantity).toFixed(3)
}
