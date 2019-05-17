export default function addressFromLocation (location) {
  const zipCode = location.country === 'Hong Kong' ? '000000' : location.zipCode

  return {
    ...location.center,
    zipCode,
    city: location.city,
    country: location.country,
    fullAddress: location.description,
    geojson: location.geojson
  }
}
