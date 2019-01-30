import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mock'

// eslint-disable-next-line no-named-as-default
import TruckingCitySetter from './TruckingCitySetter'

jest.mock('../../../hocs/GmapsWrapper', () => props => <div {...props} />)
jest.mock('../../Maps/PlaceSearch', () => props => <div {...props} />)

const newCell = {
  lower_zip: 'FOO_LOWER_ZIP',
  upper_zip: 'FOO_UPPER_ZIP'
}

const propsBase = {
  theme,
  tmpCity: {},
  newCell,
  addNewCell: identity
}

test('shallow render', () => {
  expect(shallow(<TruckingCitySetter {...propsBase} />)).toMatchSnapshot()
})

test('tmpCity is truthy', () => {
  const props = {
    ...propsBase,
    tmpCity: { city: 'CITY' }
  }
  expect(shallow(<TruckingCitySetter {...props} />)).toMatchSnapshot()
})
