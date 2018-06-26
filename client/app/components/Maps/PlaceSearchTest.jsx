import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, gMaps, theme } from '../../mocks'

/**
 * ISSUE:
 * Test can run only if
 * `gMaps: PropTypes.gMaps`
 */

// eslint-disable-next-line
import PlaceSearch from './PlaceSearch'

const propsBase = {
  theme,
  handlePlaceChange: identity,
  gMaps,
  hideMap: false,
  inputStyles: {},
  options: {}
}

test.skip('shallow render', () => {
  expect(shallow(<PlaceSearch {...propsBase} />)).toMatchSnapshot()
})
