import * as React from 'react'
import { shallow } from 'enzyme'
import CargoItemAggregated from '.'
import { cargoUnitProps, cargoItemAggregated } from '../../../mocks'
import { scope } from '../../../../../mocks/index'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

test('with empty props', () => {
  expect(() => shallow(<CargoItemAggregated />)).toThrow()
})

test('renders correctly', () => {
  const props = {
    ...cargoUnitProps,
    cargoItem: cargoItemAggregated,
    scope,
    getPropValue: (prop, cargoItem) => cargoItem[prop],
    getPropStep: (prop) => 2
  }
  expect(shallow(<CargoItemAggregated {...props} />)).toMatchSnapshot()
})
