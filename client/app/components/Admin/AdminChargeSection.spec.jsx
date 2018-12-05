import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

import AdminChargeSection from './AdminChargeSection'

const propsBase = {
  theme,
  setCurrency: identity,
  tag: 'TARGET',
  handleEdit: identity,
  value: 'VALUE',
  currency: 'CURRENCY',
  editCurr: 'EDIT_CURR',
  editVal: 'EDIT_VAL',
  editCharge: false
}

test('shallow render', () => {
  expect(shallow(<AdminChargeSection {...propsBase} />)).toMatchSnapshot()
})

test('editCharge is true', () => {
  const props = {
    ...propsBase,
    editCharge: true
  }
  expect(shallow(<AdminChargeSection {...props} />)).toMatchSnapshot()
})
