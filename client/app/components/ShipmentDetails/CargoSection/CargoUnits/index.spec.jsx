import * as React from 'react'
import { shallow } from 'enzyme'
import CargoUnits from '.'
import { cargoUnitProps, cargoItemAggregated, cargoItemContainer } from '../../mocks'

test('load type is cargo item', () => {
  expect(shallow(<CargoUnits {...cargoUnitProps} />)).toMatchSnapshot()
})

test('load type is cargo item aggregated', () => {
  const props = {
    ...cargoUnitProps,
    cargoUnits: [cargoItemAggregated],
    aggregateSection: true
  }
  expect(shallow(<CargoUnits {...props} />)).toMatchSnapshot()
})

test('load type is container', () => {
  const props = {
    ...cargoUnitProps,
    loadType: 'container',
    cargoUnits: [cargoItemContainer]
  }
  expect(shallow(<CargoUnits {...props} />)).toMatchSnapshot()
})
