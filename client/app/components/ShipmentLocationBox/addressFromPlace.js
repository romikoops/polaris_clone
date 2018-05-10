export default function addressFromPlace (place) {
  const tmpAddress = {
    number: '',
    street: '',
    zipCode: '',
    city: '',
    country: '',
    fullAddress: ''
  }

  place.address_components.forEach((ac) => {
    if (ac.types.includes('street_number')) {
      tmpAddress.number = ac.long_name
    }

    if (ac.types.includes('route') || ac.types.includes('premise')) {
      tmpAddress.street = ac.long_name
    }

    if (ac.types.includes('administrative_area_level_1')) {
      tmpAddress.city = ac.long_name
    }

    if (ac.types.includes('postal_code')) {
      tmpAddress.zipCode = ac.long_name
    }

    if (ac.types.includes('country')) {
      tmpAddress.country = ac.long_name
    }
  })
  tmpAddress.latitude = place.geometry.location.lat()
  tmpAddress.longitude = place.geometry.location.lng()
  tmpAddress.fullAddress = place.formatted_address

  return tmpAddress
}
