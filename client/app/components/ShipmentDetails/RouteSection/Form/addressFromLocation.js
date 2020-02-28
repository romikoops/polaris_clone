export default function addressFromLocation (location) {
  const zipCode = location.description.includes('Hong Kong') ? '000000' : location.postal_code

  return {
    ...location.center,
    zipCode,
    city: location.city,
    country: location.country,
    fullAddress: location.description,
    geojson: location.geojson
  }
}
