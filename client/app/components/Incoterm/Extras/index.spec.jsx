import * as React from 'react'
import { shallow } from 'enzyme'
import {
  feeHash,
  shipment,
  tenant,
  change,
  theme
} from '../../../mocks'

import IncotermExtras from '.'

const propsBase = {
  theme,
  feeHash,
  tenant,
  shipment
}

test('shallow render', () => {
  expect(shallow(<IncotermExtras {...propsBase} />)).toMatchSnapshot()
})

test('feeHash is empty object', () => {
  const props = {
    ...propsBase,
    feeHash: {}
  }
  expect(shallow(<IncotermExtras {...props} />)).toMatchSnapshot()
})

test('tenant.scope is empty object', () => {
  const props = change(
    propsBase,
    'tenant.scope',
    {}
  )
  expect(shallow(<IncotermExtras {...props} />)).toMatchSnapshot()
})
