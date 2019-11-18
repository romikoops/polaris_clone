export default function routeOption (route) {
  return {
    label: route.country ? `${route.nexusName}, ${route.country}` : route.nexusName,
    value: {
      id: route.nexusId,
      latitude: route.latitude,
      longitude: route.longitude,
      name: route.nexusName,
      country: route.country
    }
  }
}
