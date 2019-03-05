import * as React from 'react'
import { shallow } from 'enzyme'
import TruckingDetails from '.'
import { theme } from '../../mocks'

const propsBase = {
  theme,
  trucking: { TARGET: { truckType: 'chassis' } },
  truckTypes: ['side_lifter', 'chassis'],
  onTruckingDetailsChange: null,
  target: 'TARGET',
  hide: false
}

test('with empty props', () => {
  expect(() => shallow(<TruckingDetails />)).toThrow()
})

test('renders correctly', () => {
  expect(shallow(<TruckingDetails {...propsBase} />)).toMatchSnapshot()
})

test('hide is true', () => {
  const props = {
    ...propsBase,
    hide: true
  }
  expect(shallow(<TruckingDetails {...props} />)).toMatchSnapshot()
})

test('truckTypes is falsy', () => {
  const props = {
    ...propsBase,
    truckTypes: []
  }
  expect(shallow(<TruckingDetails {...props} />)).toMatchSnapshot()
})

test('target truck type is not part of truckTypes', () => {
  const props = {
    ...propsBase,
    truckTypes: ['']
  }
  expect(shallow(<TruckingDetails {...props} />)).toMatchSnapshot()
})
