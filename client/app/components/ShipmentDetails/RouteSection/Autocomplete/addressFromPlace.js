
export default function addressFromPlace (place, gMaps, map, callback) {
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

    if (ac.types.includes('locality') || ac.types.includes('administrative_area_level_3')) {
      tmpAddress.city = ac.long_name
    }

    if (ac.types.includes('postal_code')) {
      tmpAddress.zipCode = ac.long_name
    }

    if (ac.types.includes('country')) {
      tmpAddress.country = ac.long_name
    }
    if (ac.types.includes('country') && ac.long_name === 'Hong Kong') {
      tmpAddress.zipCode = '000000'
    }
  })
  tmpAddress.latitude = place.geometry.location.lat()
  tmpAddress.longitude = place.geometry.location.lng()
  tmpAddress.fullAddress = place.formatted_address

  if (!tmpAddress.city) {
    const service = new gMaps.places.PlacesService(map)
    const requestOptions = {
      location: place.geometry.location,
      rankby: 'distance',
      type: 'locality',
      radius: 10000
    }
    service.nearbySearch(requestOptions, (results) => {
      if (results && results.length > 0) {
        tmpAddress.city = results[0].name
      }
      if (!tmpAddress.city) {
        tmpAddress.city = place.address_components.find(ac => (
          ac.types.includes('administrative_area_level_1')
        )).long_name
      }
      callback(tmpAddress)
    })
  } else {
    callback(tmpAddress)
  }
}
