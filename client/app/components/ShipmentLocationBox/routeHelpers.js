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
const routeHelpers = {
  routeOption
}

export default routeHelpers
