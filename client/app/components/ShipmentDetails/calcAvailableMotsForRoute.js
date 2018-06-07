function nexusChanged (thisState, nextState, target) {
  return nextState[target] && nextState[target].nexus_id !== thisState[target].nexus_id
}

function orderedNexusIds (itinerary) {
  return itinerary.stops.map(stop => stop.hub.nexus.id)
}

function routeIsInItinerary (itinerary, origin, destination) {
  const nexusIds = orderedNexusIds(itinerary)

  return nexusIds.indexOf(origin.nexus_id) > -1 &&
  nexusIds.indexOf(origin.nexus_id) < nexusIds.indexOf(destination.nexus_id)
}

export default function calcAvailableMotsForRoute (itineraries, origin, destination) {
  const modesOfTransport = []

  if (!itineraries) return []

  itineraries.forEach((itinerary) => {
    if (modesOfTransport.includes(itinerary.modeOfTransport)) return

    if (routeIsInItinerary(itinerary, origin, destination)) {
      modesOfTransport.push(itinerary.modeOfTransport)
    }
  })
  return modesOfTransport
}

export function shouldUpdateAvailableMotsForRoute (thisState, nextState) {
  return ['origin', 'destination'].some(target => nexusChanged(thisState, nextState, target))
}
