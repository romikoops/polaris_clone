export default function calcAvailableMotsForRoute (
  routes,
  lookupTablesForRoutes,
  filteredRouteIndexes
) {
  const modesOfTransport = []
  filteredRouteIndexes.selected.forEach((idx) => {
    const { modeOfTransport } = routes[idx]
    if (modesOfTransport.includes(modeOfTransport)) return

    modesOfTransport.push(modeOfTransport)
  })

  return modesOfTransport
}

export function shouldUpdateAvailableMotsForRoute (
  thisStateFilteredRouteIndexes,
  nextStateFilteredRouteIndexes
) {
  for (let i = 0; i < thisStateFilteredRouteIndexes.selected.length; i++) {
    if (thisStateFilteredRouteIndexes.selected[i] !== nextStateFilteredRouteIndexes.selected[i]) {
      return true
    }
  }

  return false
}
