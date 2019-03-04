export default function addressFromLocation (location) {
  return {
    ...location.center,
    zipCode: location.postal_code,
    city: location.city,
    country: location.country,
    fullAddress: location.description,
    geojson: location.geojson
  }
}
