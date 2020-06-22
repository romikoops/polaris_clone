import * as React from 'react'
import { shallow, mount } from 'enzyme'
import Formsy from 'formsy-react'
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

describe('#getVolumeErrors', () => {
  const getVolumeErrors = (extraProps) => {
    const mounted = mount(<CargoItem {...props} {...extraProps} />, { wrappingComponent: Formsy })

    return mounted.instance().getVolumeErrors
  }

  const buildMaxDimensions = () => ({
    general: { width: '1.0', length: '1.0', height: '1.0', volume: '1.0' },
    ocean: { width: '1.0', length: '1.0', height: '1.0', volume: '1.0' },
    truckCarriage: { width: '1.0', length: '1.0', height: '1.0', volume: '1.0' }
  })

  const props = {
    ...cargoUnitProps,
    i: 0,
    cargoItem,
    scope,
    getPropValue: (prop, _cargoItem) => cargoItem[prop],
    getPropStep: (prop) => 2,
    maxDimensions: buildMaxDimensions(),
    totalShipmentErrors: {
      chargeableWeight: {},
      payloadInKg: {},
      volume: {}
    },
    preCarriage: true
  }

  it('returns error if the truckCarriage exceed', () => {
    const maxDimensions = buildMaxDimensions()
    maxDimensions.truckCarriage.volume = '0.00001'

    expect(getVolumeErrors({ maxDimensions })).toEqual({ mots: ['truckCarriage'], type: 'error' })
  })

  it('returns warning if one of mot`s exceed', () => {
    const maxDimensions = buildMaxDimensions()
    maxDimensions.ocean.volume = '0.00001'

    expect(getVolumeErrors({ maxDimensions })).toEqual({ mots: ['ocean'], type: 'warning' })
  })

  it('returns error if all of mot`s exceed', () => {
    const maxDimensions = buildMaxDimensions()
    maxDimensions.general.volume = '0.00001'
    maxDimensions.ocean.volume = '0.00001'

    expect(getVolumeErrors({ maxDimensions })).toEqual({ mots: ['ocean', 'air'], type: 'error' })
  })
})
