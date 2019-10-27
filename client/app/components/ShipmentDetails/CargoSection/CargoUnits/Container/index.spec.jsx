import * as React from 'react'
import { shallow } from 'enzyme'
import Container from '.'
import { cargoItemContainer, cargoUnitProps, ShipmentDetails } from '../../../mocks'
import { scope } from '../../../../../mocks/index'

test('with empty props', () => {
  expect(() => shallow(<Container />)).toThrow()
})

test('renders correctly', () => {
  const props = {
    ...cargoUnitProps,
    container: cargoItemContainer,
    ShipmentDetails,
    scope,
    getPropValue: (prop, cargoItem) => cargoItem[prop],
    getPropStep: (prop) => 2
  }
  expect(shallow(<Container {...props} />)).toMatchSnapshot()
})
