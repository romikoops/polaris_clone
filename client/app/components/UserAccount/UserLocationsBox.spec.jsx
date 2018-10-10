import * as React from 'react'
import { shallow } from 'enzyme'
import UserLocationsBox from './UserLocationsBox'

test('shallow render', () => {
  expect(shallow(<UserLocationsBox />)).toMatchSnapshot()
})
