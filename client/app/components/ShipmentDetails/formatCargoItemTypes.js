export default function formatCargoItemTypes (cargoItemTypes) {
  if (!(Array.isArray(cargoItemTypes))) return []
  const palletType = cargoItemTypes.filter(colli => colli.description === 'Pallet')
  const nonPalletTypes = cargoItemTypes.filter(colli => colli.description !== 'Pallet')
  nonPalletTypes.unshift(palletType[0])
  return nonPalletTypes.map(cargoItemType => ({
    label: cargoItemType.description,
    key: cargoItemType.id,
    dimension_x: cargoItemType.dimension_x,
    dimension_y: cargoItemType.dimension_y
  }))
}
