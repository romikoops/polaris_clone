import * as React from 'react'
import { mount } from 'enzyme'
import { omit } from 'lodash'
import { identity, change } from '../../../mocks'
// eslint-disable-next-line no-named-as-default
import PanelBox from './PanelBox'

const cellsBase = {
  lower_distance: {
    table: [{ value: 'NESTED_TABLE_VALUE', fees: ['NESTED_TABLE_FEES'] }],
    CELL_UPPER_KEY: 'LOWER_DISTANCE_CELL_UPPER_KEY',
    CELL_LOWER_KEY: 'LOWER_DISTANCE_CELL_LOWER_KEY'
  },
  upper_distance: {},
  table: { 0: { value: 'CELL_TABLE_VALUE' } }
}

const cellStepsBase = {
  lower_distance: {
    table: {}
  },
  city: 'CITY',
  country: 'COUNTRY'
}

const propsBase = {
  cells: [cellsBase],
  cellSteps: [cellStepsBase],
  handleRateChange: identity,
  shrinkPanel: identity,
  shrinkView: {},
  lowerKey: 'LOWER_KEY',
  upperKey: 'UPPER_KEY',
  handleMinimumChange: identity,
  target: 'lower_distance',
  stepBasis: { label: 'STEP_BASIS_LABEL' },
  truckingBasis: { label: 'TRACKING_BASIS_LABEL' },
  cellUpperKey: 'CELL_UPPER_KEY',
  cellLowerKey: 'CELL_LOWER_KEY'
}

test('shallow render', () => {
  expect(mount(<PanelBox {...propsBase} />)).toMatchSnapshot()
})

test('cellStep.city is falsy', () => {
  const cellSteps = omit(cellStepsBase, 'city')
  const props = {
    ...propsBase,
    cellSteps: [cellSteps]
  }
  expect(mount(<PanelBox {...props} />)).toMatchSnapshot()
})

test('cellLowerKey is city', () => {
  const props = {
    ...propsBase,
    cellLowerKey: 'city'
  }
  expect(mount(<PanelBox {...props} />)).toMatchSnapshot()
})

test('fee.cbm !== undefined && fee.kg !== undefined', () => {
  const cells = change(
    cellsBase,
    'lower_distance',
    {
      table: [{
        value: 'NESTED_TABLE_VALUE',
        fees: { foo: { cbm: 'FEES_CBM', kg: 'FEES_KG' } }
      }]
    }
  )
  const props = {
    ...propsBase,
    cells: [cells]
  }
  expect(mount(<PanelBox {...props} />)).toMatchSnapshot()
})

test('fee.cbm !== undefined && fee.ton !== undefined', () => {
  const cells = change(
    cellsBase,
    'lower_distance',
    {
      table: [{
        value: 'NESTED_TABLE_VALUE',
        fees: { foo: { cbm: 'FEES_CBM', ton: 'FEES_TON' } }
      }]
    }
  )
  const props = {
    ...propsBase,
    cells: [cells]
  }
  expect(mount(<PanelBox {...props} />)).toMatchSnapshot()
})
