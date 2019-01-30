import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../mock'

import AdminExportChargePanel from './AdminExportChargePanel'

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
  target: 'TARGET',
  hub: {
    ...hub,
    data: {
      name: 'NAME'
    }
  },
  charge: {
    foo: {
      trade_direction: 'export'
    }
  },
  navFn: identity,
  backFn: identity
}

test('shallow render', () => {
  expect(shallow(<AdminExportChargePanel {...propsBase} />)).toMatchSnapshot()
})

test('charge is falsy', () => {
  const props = {
    ...propsBase,
    charge: null
  }

  expect(shallow(<AdminExportChargePanel {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }

  expect(shallow(<AdminExportChargePanel {...props} />)).toMatchSnapshot()
})
