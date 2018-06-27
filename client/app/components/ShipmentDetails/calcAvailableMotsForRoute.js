export default function calcAvailableMotsForRoute (
  routes,
  lookupTablesForRoutes,
  filteredRouteIndexes
) {
  const modesOfTransport = []
  filteredRouteIndexes.forEach((idx) => {
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
  for (let i = 0; i < thisStateFilteredRouteIndexes.length; i++) {
    if (thisStateFilteredRouteIndexes[i] !== nextStateFilteredRouteIndexes[i]) {
      return true
    }
  }

  return false
}
