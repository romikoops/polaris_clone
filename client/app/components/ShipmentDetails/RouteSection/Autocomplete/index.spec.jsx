import * as React from 'react'
import { shallow } from 'enzyme'
import Autocomplete from '.'
import {
  scope,
  theme
} from '../../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const propsBase = {
  theme,
  scope,
  target: 'TARGET'
}

test('with empty props', () => {
  expect(() => shallow(<Autocomplete />)).toThrow()
})

test('renders correctly', () => {
  expect(shallow(<Autocomplete {...propsBase} />)).toMatchSnapshot()
})

import addressFromPlace from './addressFromPlace'

test('replaces the missing postal code from place', () => {
  const result = addressFromPlace({
    address_components: [
    {
      long_name: "Langham Place Shopping Mall",
      short_name: "Langham Place Shopping Mall",
      types: ['premise']
    },
    {long_name: "8",
    short_name: "8",
    types: ["street_number"]
    },
    {long_name: "Argyle Street",
    short_name: "Argyle St",
    types: ["route"]
    },
    {long_name: "Mong Kok",
    short_name: "Mong Kok",
    types: ["neighborhood", "political"]
    },
    {long_name: "Kowloon",
    short_name: "Kowloon",
    types: ["administrative_area_level_1", "political"]
    },
    {long_name: "Hong Kong",
    short_name: "HK",
    types: ["locality"]},
    {long_name: "Hong Kong",
    short_name: "HK",
    types: ["country", "political"]}
    ],
    formatted_address: "Langham Place Shopping Mall, 8 Argyle St, Mong Kok, Hong Kong",
    geometry: {location: {
      lat: () => 22.3179137,
      lng: () => 114.16874419999999
    }, viewport: {}},
    html_attributions: [],
    icon: "https://maps.gstatic.com/mapfiles/place_api/icons/geocode-71.png",
    id: "b8fe5a1c2e955f754605a3ba08f069ed6d93c9be",
    name: "Langham Place Shopping Mall",
    place_id: "ChIJPadWmscABDQRBsYdT0BZvVY",
    reference: "ChIJPadWmscABDQRBsYdT0BZvVY",
    scope: "GOOGLE",
    types: ["premise"],
    url: "https://maps.google.com/?q=Langham+Place+Shopping+Mall&ftid=0x340400c79a56a73d:0x56bd59404f1dc606",
    utc_offset: 480,
    website: "http://www.langhamplace.com.hk/",
  }, null, null, null)

  expect(result).toEqual({
    number: '8',
    street: 'Argyle Street',
    zipCode: '000000',
    city: 'Hong Kong',
    fullAddress: "Langham Place Shopping Mall, 8 Argyle St, Mong Kok, Hong Kong",
    latitude: 22.3179137,
    longitude: 114.16874419999999,
    country: 'Hong Kong'
  })
})
import addressFromLocation from './addressFromLocation'

test('replaces the missing postal code from location', () => {
  const result = addressFromLocation({
    center: {latitude: 22.3208912, longitude: 114.155388},
    city: "Hong Kong",
    country: "Hong Kong",
    description: "Hampton Place, Yau Tsim Mong District, Kowloon, Hong Kong, Hong Kong",
    geojson: null,
    postal_code: null
  })

  expect(result).toEqual({
    zipCode: '000000',
    geojson: null,
    city: 'Hong Kong',    
    fullAddress: "Hampton Place, Yau Tsim Mong District, Kowloon, Hong Kong, Hong Kong",
    latitude: 22.3208912,
    longitude: 114.155388,
    country: 'Hong Kong'
  })
})