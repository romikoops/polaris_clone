import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks/index'
import TruckingDetails from './TruckingDetails'

const propsBase = {
  theme,
  target: 'on_carriage',
  trucking: {
    on_carriage: {
      truck: 'TRUCK_ON_CARRIAGE'
    },
    pre_carriage: {
      truck: 'TRUCK_PRE_CARRIAGE'
    }
  },
  truckTypes: ['foo', 'chassis'],
  handleTruckingDetailsChange: identity
}

test('shallow render', () => {
  expect(shallow(<TruckingDetails {...propsBase} />)).toMatchSnapshot()
})
test('truckTypes.length === 0', () => {
  const props = {
    ...propsBase,
    truckTypes: []
  }
  expect(shallow(<TruckingDetails {...props} />)).toMatchSnapshot()
})
