function routeOption (route) {
  return {
    label: route.nexusName,
    value: {
      id: route.nexusId,
      latitude: route.latitude,
      longitude: route.longitude,
      name: route.nexusName
    }
  }
}

function centerFromGeoJson (lats, lngs) {
  const reducer = (accumulator, currentValue) => accumulator + currentValue;
  const centerLat = lats.reduce(reducer) / lats.length
  const centerLng = lngs.reduce(reducer) / lngs.length
  return { lat: centerLat, lng: centerLng }
}
const routeHelpers = {
  routeOption,
  centerFromGeoJson
}

export default routeHelpers
