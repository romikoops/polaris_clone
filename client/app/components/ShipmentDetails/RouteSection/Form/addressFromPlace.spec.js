import addressFromPlace from './addressFromPlace'

const mockPlace = {
  address_components: [
    { long_name: '1', short_name: '1', types: ['street_number'] },
    { long_name: 'A', short_name: 'A', types: ['route'] },
    { long_name: 'B', short_name: 'B', types: ['locality'] },
    { long_name: 'C', short_name: 'C', types: ['postal_code'] },
    { long_name: 'D', short_name: 'D', types: ['country'] }
  ],
  geometry: {
    location: {
      lat: () => 10.0,
      lng: () => 50.0
    }
  }
}
const mockGMaps = (x) => (x)
const map = {}

const expectedResults = {
  street: 'A',
  number: '1',
  city: 'B',
  zipCode: 'C',
  country: 'D',
  latitude: 10.0,
  longitude: 50.0
}

test('should return the correct object', () => {
  expect(addressFromPlace(mockPlace, mockGMaps, map)).toEqual(expectedResults)
})
