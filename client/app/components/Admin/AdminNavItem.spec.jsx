import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

import AdminNavItem from './AdminNavItem'

const propsBase = {
  theme,
  iconClass: 'ICON',
  text: 'TEXT',
  navFn: identity,
  target: 'TARGET',
  tooltip: 'TOOLTIP'
}

test('shallow render', () => {
  expect(shallow(<AdminNavItem {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminNavItem {...props} />)).toMatchSnapshot()
})
