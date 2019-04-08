import * as React from 'react'
import { shallow } from 'enzyme'
import Container from '.'
import { cargoItemContainer, cargoUnitProps, ShipmentDetails } from '../../../mocks'

test('with empty props', () => {
  expect(() => shallow(<Container />)).toThrow()
})

test('renders correctly', () => {
  const props = {
    ...cargoUnitProps,
    container: cargoItemContainer,
    ShipmentDetails
  }
  expect(shallow(<Container {...props} />)).toMatchSnapshot()
})
