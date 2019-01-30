import * as React from 'react'
import { mount } from 'enzyme'
import { theme, identity } from '../../../mock'
// eslint-disable-next-line no-named-as-default
import TruckingZipPanel from './TruckingZipPanel'

const cells = [{
  lower_distance: 'FOO_LOWER_DISTANCE',
  upper_distance: 'FOO_UPPER_DISTANCE',
  table: { 0: { value: 'FOO_CELL_VALUE' } }
}]

const weightSteps = [{
  city: 'FOO_CITY',
  country: 'FOO_COUNTRY',
  max: 'FOO_MAX',
  min: 'FOO_MIN'
}]

const propsBase = {
  theme,
  cells,
  loadType: { value: 'fcl' },
  weightSteps,
  rateBasis: { label: 'FOO_RATEBASIS_LABEL' },
  currency: { label: 'FOO_CURRENCY_LABEL' },
  handleRateChange: identity,
  handleMinimumChange: identity
}

test('shallow render', () => {
  expect(mount(<TruckingZipPanel {...propsBase} />)).toMatchSnapshot()
})
