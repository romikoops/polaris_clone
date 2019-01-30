export const firstAddress = {
  user: {
    primary: true
  },
  primary: true,
  id: 246,
  streetNumber: 'FOO_ADDRESS_STREET_NUMBER',
  geocodedAddress: 'FOO_GEOCODED_ADDRESS',
  street: 'FOO_ADDRESS_STREET',
  city: 'FOO_ADDRESS_CITY',
  zipCode: 'FOO_ADDRESS_ZIP_CODE',
  country: 'FOO_ADDRESS_COUNTRY'
}

export const secondAddress = {
  user: {
    primary: false
  },
  primary: false,
  id: 704,
  streetNumber: 'BAR_ADDRESS_STREET_NUMBER',
  geocodedAddress: 'BAR_GEOCODED_ADDRESS',
  street: 'BAR_ADDRESS_STREET',
  city: 'BAR_ADDRESS_CITY',
  zipCode: 'BAR_ADDRESS_ZIP_CODE',
  country: 'BAR_ADDRESS_COUNTRY'
}

export const originAddress = {
  city: 'ORIGIN_ADDRESS_CITY',
  country: 'ORIGIN_ADDRESS_COUNTRY',
  street: 'ORIGIN_ADDRESS_STREET',
  street_number: 'ORIGIN_ADDRESS_STREET_NUMBER',
  zip_code: 'ORIGIN_ADDRESS_ZIP_CODE'
}
export const destinationAddress = {
  city: 'DESTINATION_ADDRESS_CITY',
  country: 'DESTINATION_ADDRESS_COUNTRY',
  street: 'DESTINATION_ADDRESS_STREET',
  street_number: 'DESTINATION_ADDRESS_STREET_NUMBER',
  zip_code: 'DESTINATION_ADDRESS_ZIP_CODE'
}

export const addresses = {
  origin: originAddress,
  destination: destinationAddress
}
