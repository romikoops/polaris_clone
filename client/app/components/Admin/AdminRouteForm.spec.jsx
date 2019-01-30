import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../mock'

import AdminRouteForm from './AdminRouteForm'

const propsBase = {
  theme,
  saveRoute: identity,
  close: identity,
  hubs: [{
    ...hub,
    data: {
      id: 7,
      name: 'NAME'
    }
  }]
}

test('shallow render', () => {
  expect(shallow(<AdminRouteForm {...propsBase} />)).toMatchSnapshot()
})

test('hubs if falsy', () => {
  const props = {
    ...propsBase,
    hubs: null
  }
  expect(shallow(<AdminRouteForm {...props} />)).toMatchSnapshot()
})

test('theme if falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminRouteForm {...props} />)).toMatchSnapshot()
})
