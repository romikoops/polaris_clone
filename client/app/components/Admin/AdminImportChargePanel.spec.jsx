import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../mock'
import AdminImportChargePanel from './AdminImportChargePanel'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  theme,
  hub: {
    ...hub,
    data: { name: 'NAME' }
  },
  charge: {
    foo: { trade_direction: 'import', value: 'VALUE', currency: 'CURRENCY' }
  },
  navFn: identity,
  backFn: identity,
  target: 'TARGET'
}

test('shallow render', () => {
  expect(shallow(<AdminImportChargePanel {...propsBase} />)).toMatchSnapshot()
})

test('hub is falsy', () => {
  const props = {
    ...propsBase,
    hub: null
  }

  expect(shallow(<AdminImportChargePanel {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }

  expect(shallow(<AdminImportChargePanel {...props} />)).toMatchSnapshot()
})
