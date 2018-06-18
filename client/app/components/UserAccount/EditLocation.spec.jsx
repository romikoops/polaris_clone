import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, gMaps, location } from '../../mocks'

jest.mock('react-redux', () => ({
  connect: () => Component => Component
}))
// eslint-disable-next-line
import EditLocation from './EditLocation'

const propsBase = {
  theme,
  toggleActiveView: identity,
  saveLocation: identity,
  gMaps,
  geocodedAddress: 'FOO_GEO_ADDRESS',
  location
}

test('shallow render', () => {
  expect(shallow(<EditLocation {...propsBase} />)).toMatchSnapshot()
})
