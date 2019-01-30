import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../mock'

import ItineraryRow from './ItineraryRow'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const itineraryBase = {
  name: 'FOO - BAR',
  mode_of_transport: 'air'
}

const propsBase = {
  itinerary: itineraryBase,
  adminDispatch: {},
  theme
}

test('shallow render', () => {
  expect(shallow(<ItineraryRow {...propsBase} />)).toMatchSnapshot()
})
