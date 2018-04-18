export default function formatCargoItemTypes (cargoItemTypes) {
  if (!(Array.isArray(cargoItemTypes))) return []

  return cargoItemTypes.map(cargoItemType => ({
    label: cargoItemType.description,
    key: cargoItemType.id,
    dimension_x: cargoItemType.dimension_x,
    dimension_y: cargoItemType.dimension_y
  }))
}
