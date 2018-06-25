
function selectFromLookupTable (lookupTablesForRoutes, targetIds, target) {
  const results = []
  targetIds.forEach((targetId) => {
    const lookup = lookupTablesForRoutes[target][targetId]
    lookup.forEach((ri) => {
      if (!results.includes(ri)) {
        results.push(ri)
      }
    })
  })
  return results
}

function scopeIndexes (prevIndexes, indexes) {
  const prevIndexSet = Array.from(new Set(prevIndexes))
  const indexSet = Array.from(new Set(indexes))
  const intersection =
    new Set(prevIndexSet.filter(prevIndex => indexSet.has(prevIndex)))

  return Array.from(intersection)
}

function getHubIds (indexes, lookupTablesForRoutes, routes, target) {
  if (!indexes.length) {
    return Object.keys(lookupTablesForRoutes[`${target}Hub`])
  }
  return [...new Set(indexes.map(index => routes[index][target].hubId))]
}
function getNexusOption (nexusId, lookupTablesForRoutes, routes, target) {
  const targetNexus = routes[lookupTablesForRoutes[`${target}Nexus`][nexusId][0]][target]
  const option = {
    label: targetNexus.nexusName,
    value: {
      id: targetNexus.nexusId,
      latitude: targetNexus.latitude,
      longitude: targetNexus.longitude,
      name: targetNexus.nexusName
    }
  }

  return option
}

const routeFilters = {
  selectFromLookupTable,
  scopeIndexes,
  getHubIds,
  getNexusOption
}

export default routeFilters
