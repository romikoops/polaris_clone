import * as React from 'react'
import { mount } from 'enzyme'
import { theme, identity } from '../../../mock'
// eslint-disable-next-line no-named-as-default
import TruckingZipSetter from './TruckingZipSetter'

const newCell = {
  lower_zip: 'FOO_LOWER_ZIP',
  upper_zip: 'FOO_UPPER_ZIP'
}

const propsBase = {
  theme,
  newCell,
  addNewCell: identity
}

test.skip('shallow render', () => {
  expect(mount(<TruckingZipSetter {...propsBase} />)).toMatchSnapshot()
})
