import * as React from 'react'
import { shallow } from 'enzyme'
import CargoItemAggregated from '.'
import { importedProps, cargoItemAggregated } from '../../../mocks'

test('with empty props', () => {
  expect(() => shallow(<CargoItemAggregated />)).toThrow()
})

test('happy path', () => {
  const props = {
    ...importedProps,
    cargoItem: cargoItemAggregated
  }
  expect(shallow(<CargoItemAggregated {...props} />)).toMatchSnapshot()
})
