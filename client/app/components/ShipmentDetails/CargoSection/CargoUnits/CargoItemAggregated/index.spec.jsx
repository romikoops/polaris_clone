import * as React from 'react'
import { shallow } from 'enzyme'
import CargoItemAggregated from '.'
import { cargoUnitProps, cargoItemAggregated } from '../../../mocks'

test('with empty props', () => {
  expect(() => shallow(<CargoItemAggregated />)).toThrow()
})

test('happy path', () => {
  const props = {
    ...cargoUnitProps,
    cargoItem: cargoItemAggregated
  }
  expect(shallow(<CargoItemAggregated {...props} />)).toMatchSnapshot()
})
