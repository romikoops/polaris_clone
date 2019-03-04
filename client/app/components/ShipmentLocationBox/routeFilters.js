
function selectFromLookupTable (lookupTablesForRoutes, targetIds, target) {
  const results = []
  targetIds.forEach((targetId) => {
    const lookup = lookupTablesForRoutes[target][targetId] || []
    lookup.forEach((ri) => {
      if (!results.includes(ri)) {
        results.push(ri)
      }
    })
  })

  return results
}

function scopeIndexes (prevIndexes, indexes) {
  const indexSet = new Set(indexes)
  const intersection = new Set(prevIndexes.filter(prevIndex => indexSet.has(prevIndex)))

  return Array.from(intersection)
}

function getHubIds (indexes, lookupTablesForRoutes, routes, target) {
  if (!indexes.length) {
    return Object.keys(lookupTablesForRoutes[`${target}Hub`])
  }
  return Array.from(new Set(indexes.map(index => routes[index][target].hubId)))
}

function getNexusOption (nexusId, lookupTablesForRoutes, routes, target) {
  if (lookupTablesForRoutes[`${target}Nexus`] &&
  lookupTablesForRoutes[`${target}Nexus`][nexusId] &&
  lookupTablesForRoutes[`${target}Nexus`][nexusId][0]) {
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

  return false
}

const routeFilters = {
  selectFromLookupTable,
  scopeIndexes,
  getHubIds,
  getNexusOption
}

export default routeFilters
