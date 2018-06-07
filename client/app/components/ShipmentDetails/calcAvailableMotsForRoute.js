function nexusChanged (thisState, nextState, target) {
  if (!nextState[target]) return false

  return (
    nextState[target].nexus_id !== thisState[target].nexus_id ||
    (
      Array.isArray(nextState[target].nexusIds) &&
      Array.isArray(thisState[target].nexusIds) &&
      nextState[target].nexusIds.some((nexusId, i) => (
        nexusId !== thisState[target].nexusIds[i]
      ))
    )
  )
}

function extractNexusIdsFromTarget (target) {
  return target.nexus_id ? [target.nexus_id] : target.nexusIds
}

function orderedNexusIds (itinerary) {
  return itinerary.stops.map(stop => stop.hub.nexus.id)
}

function routeIsInItinerary (itinerary, originNexusId, destinationNexusId) {
  const nexusIds = orderedNexusIds(itinerary)

  return nexusIds.indexOf(originNexusId) > -1 &&
  nexusIds.indexOf(originNexusId) < nexusIds.indexOf(destinationNexusId)
}

export default function calcAvailableMotsForRoute (itineraries, origin, destination) {
  const modesOfTransport = []
  if (!itineraries) return []

  const originNexusIds = extractNexusIdsFromTarget(origin)
  const destinationNexusIds = extractNexusIdsFromTarget(destination)
  if (!originNexusIds || !destinationNexusIds) return []

  originNexusIds.forEach((originNexusId) => {
    destinationNexusIds.forEach((destinationNexusId) => {
      itineraries.forEach((itinerary) => {
        if (modesOfTransport.includes(itinerary.modeOfTransport)) return

        if (routeIsInItinerary(itinerary, originNexusId, destinationNexusId)) {
          modesOfTransport.push(itinerary.modeOfTransport)
        }
      })
    })
  })

  return modesOfTransport
}

export function shouldUpdateAvailableMotsForRoute (thisState, nextState) {
  return ['origin', 'destination'].some(target => nexusChanged(thisState, nextState, target))
}
