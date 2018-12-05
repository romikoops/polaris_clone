import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../mocks'

import AdminChargePanel from './AdminChargePanel'

const propsBase = {
  theme,
  navFn: identity,
  backFn: identity,
  target: 'T',
  adminTools: {
    updateServiceCharge: identity
  },
  charge: {
    foo: {
      trade_direction: 'import'
    },
    bar: {
      trade_direction: 'export'
    }
  },
  hub
}

test('shallow render', () => {
  expect(shallow(<AdminChargePanel {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminChargePanel {...props} />)).toMatchSnapshot()
})

test('hub is falsy', () => {
  const props = {
    ...propsBase,
    hub: null
  }
  expect(shallow(<AdminChargePanel {...props} />)).toMatchSnapshot()
})

test('state.editCharge is true', () => {
  const wrapper = shallow(<AdminChargePanel {...propsBase} />)
  wrapper.setState({ editCharge: true })

  expect(wrapper).toMatchSnapshot()
})
