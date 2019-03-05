import * as React from 'react'
import { shallow } from 'enzyme'
import CargoItem from '.'
import { cargoUnitProps, cargoItem, cargoItemTypes } from '../../../mocks'

test('with empty props', () => {
  expect(() => shallow(<CargoItem />)).toThrow()
})

test('renders correcly', () => {
  const props = {
    ...cargoUnitProps,
    i: 0,
    cargoItem
  }
  expect(shallow(<CargoItem {...props} />)).toMatchSnapshot()
})

test('getSelectedColliType returns correct value', () => {
  const result = CargoItem.getSelectedColliType(cargoItemTypes, 23)
  const expected = { label: 'Crate', value: 'Crate' }
  expect(result).toEqual(expected)
})

test('getSelectedColliType with undefined as type id', () => {
  const result = CargoItem.getSelectedColliType(cargoItemTypes)
  expect(result).toBeUndefined()
})

test('getAvailableCargoItemTypes with undefined input', () => {
  const result = CargoItem.getAvailableCargoItemTypes()
  expect(result).toEqual([])
})

test('getAvailableCargoItemTypes returns correct value', () => {
  const result = CargoItem.getAvailableCargoItemTypes(cargoItemTypes)
  const expected = [{
    label: 'Pallet', key: 25, dimension_x: null, dimension_y: null
  },
  {
    label: 'Carton', key: 22, dimension_x: null, dimension_y: null
  },
  {
    label: 'Crate', key: 23, dimension_x: null, dimension_y: null
  },
  {
    label: 'Bottle', key: 26, dimension_x: null, dimension_y: null
  },
  {
    label: 'Stack', key: 27, dimension_x: null, dimension_y: null
  },
  {
    label: 'Drum', key: 28, dimension_x: null, dimension_y: null
  },
  {
    label: 'Skid', key: 29, dimension_x: null, dimension_y: null
  },
  {
    label: 'Barrel', key: 30, dimension_x: null, dimension_y: null
  }]
  expect(result).toEqual(expected)
})
