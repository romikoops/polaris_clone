import * as React from 'react'
import { shallow } from 'enzyme'
import CargoUnits from '.'
import { importedProps, cargoItemAggregated, cargoItemContainer } from '../../mocks'

test('with empty props', () => {
  expect(shallow(<CargoUnits />)).toMatchSnapshot()
})

test('load type is cargo item', () => {
  expect(shallow(<CargoUnits {...importedProps} />)).toMatchSnapshot()
})

test('load type is cargo item aggregated', () => {
  const props = {
    ...importedProps,
    cargoUnits: [cargoItemAggregated],
    aggregatedCargo: true
  }
  expect(shallow(<CargoUnits {...props} />)).toMatchSnapshot()
})

test('load type is container', () => {
  const props = {
    ...importedProps,
    loadType: 'container',
    cargoUnits: [cargoItemContainer]
  }
  expect(shallow(<CargoUnits {...props} />)).toMatchSnapshot()
})
