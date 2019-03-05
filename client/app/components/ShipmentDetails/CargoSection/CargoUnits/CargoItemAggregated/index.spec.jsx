import * as React from 'react'
import { shallow } from 'enzyme'
import CargoItemAggregated from '.'
import { cargoUnitProps, cargoItemAggregated } from '../../../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

test('with empty props', () => {
  expect(() => shallow(<CargoItemAggregated />)).toThrow()
})

test('renders correctly', () => {
  const props = {
    ...cargoUnitProps,
    cargoItem: cargoItemAggregated
  }
  expect(shallow(<CargoItemAggregated {...props} />)).toMatchSnapshot()
})
