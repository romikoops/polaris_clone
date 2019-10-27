export const CONTAINER_TYPES = [
  { type: "fcl_10", label: "Dry Container 10'", weight: 0, order: 1 },
  { type: 'fcl_20', label: "Dry Container 20'", weight: 2370, order: 2 },
  { type: 'fcl_40', label: "Dry Container 40'", weight: 3750, order: 3 },
  { type: 'fcl_45', label: "Dry Container 45'", order: 4 },
  { type: 'fcl_40_hq', label: "High Cube 40'", weight: 4000, order: 5 },
  { type: 'fcl_45_hq', label: "High Cube 45'", weight: 4800, order: 6 },
  { type: '', label: "Hardtop 20'", weight: 2500, order: 7 },
  { type: '', label: "Hardtop 40'", weight: 2500, order: 8 },
  { type: '', label: "Hardtop High Cube 40'", weight: 2500, order: 9 },
  { type: 'fcl_20_ot', label: "Open Top 20'", weight: 2500, order: 10 },
  { type: 'fcl_40_ot', label: "Open Top 40'", weight: 4000, order: 11 },
  { type: '', label: "Flat 20'", weight: 0, order: 12 },
  { type: '', label: "Flat High Cube 40'", weight: 0, order: 13 },
  { type: '', label: "Flat Platform 20' ", weight: 0, order: 14 },
  { type: '', label: "Flat Platform 40'", weight: 0, order: 15 },
  { type: '', label: "Ventilated 20'", weight: 0, order: 16 },
  { type: '', label: "Ventilated 40'", weight: 0, order: 17 },
  { type: '', label: "Insulated 20'", weight: 0, order: 18 },
  { type: '', label: "Insulated 40'", weight: 0, order: 19 },
  { type: '', label: "Bulk Container 20'", weight: 0, order: 20 },
  { type: 'fcl_20_rf', label: "Refrigerated 20'", weight: 0, order: 21 },
  { type: 'fcl_40_rf', label: "Refrigerated 40'", weight: 0, order: 22 },
  { type: '', label: "High Cube Refrigerated 40'", weight: 0, order: 23 },
  { type: '', label: "Tank 20'", weight: 0, order: 24 },
  { type: '', label: "Flexitank", weight: 0, order: 25 },
  { type: 'lcl', label: 'LCL', weight: 0, order: 26 }
]

export const CONTAINER_DESCRIPTIONS = CONTAINER_TYPES.reduce((obj, item) => {
  // eslint-disable-next-line no-param-reassign
  obj[item.type] = item.label

  return obj
}, {})

export const CONTAINER_TARE_WEIGHTS = CONTAINER_TYPES.reduce((obj, item) => {
  // eslint-disable-next-line no-param-reassign
  obj[item.type] = item.weight

  return obj
}, {})
