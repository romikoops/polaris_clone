import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks/index'

import { NavSidebar } from './NavSidebar'

const navLink = {
  url: 'URL',
  target: 'TARGET',
  text: 'TEXT',
  icon: 'ICON'
}

const propsBase = {
  theme,
  toggleActiveClass: identity,
  navLinkInfo: [navLink]
}

test('shallow rendering', () => {
  expect(shallow(<NavSidebar {...propsBase} />)).toMatchSnapshot()
})
