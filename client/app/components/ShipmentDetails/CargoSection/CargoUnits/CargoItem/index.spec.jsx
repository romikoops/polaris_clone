import * as React from 'react'
import { shallow } from 'enzyme'
import CargoItem from '.'
import { scope } from '../../../../../mocks/index'
import { cargoItemTypes, cargoUnitProps, cargoItem } from '../../../mocks'

test('with empty props', () => {
  expect(() => shallow(<CargoItem />)).toThrow()
})

test('renders correcly', () => {
  const props = {
    ...cargoUnitProps,
    i: 0,
    cargoItem,
    scope,
    getPropValue: (prop, cargoItem) => cargoItem[prop],
    getPropStep: (prop) => 2
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
    label: 'Pallet', key: 25, width: null, length: null
  },
  {
    label: 'Carton', key: 22, width: null, length: null
  },
  {
    label: 'Crate', key: 23, width: null, length: null
  },
  {
    label: 'Bottle', key: 26, width: null, length: null
  },
  {
    label: 'Stack', key: 27, width: null, length: null
  },
  {
    label: 'Drum', key: 28, width: null, length: null
  },
  {
    label: 'Skid', key: 29, width: null, length: null
  },
  {
    label: 'Barrel', key: 30, width: null, length: null
  }]
  expect(result).toEqual(expected)
})
