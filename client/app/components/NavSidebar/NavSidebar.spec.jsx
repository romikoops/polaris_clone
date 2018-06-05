import * as React from 'react'
import { shallow as shallowMethod } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('../../components/Admin/AdminNavItem', () => {
  // eslint-disable-next-line react/prop-types
  const AdminNavItem = ({ children }) => <div>{children}</div>

  return { AdminNavItem }
})

jest.mock('uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))

// eslint-disable-next-line
import { NavSidebar } from './NavSidebar'

const navLink = {
  url: 'FOO_URL',
  target: 'FOO_TARGET',
  text: 'FOO_TEXT',
  icon: 'FOO_ICON'
}

const propsBase = {
  theme,
  toggleActiveClass: identity,
  navLinkInfo: [navLink]
}

const createShallow = propsInput => shallowMethod(<NavSidebar {...propsInput} />)

test('shallow rendering', () => {
  const shallow = createShallow(propsBase)

  expect(shallow).toMatchSnapshot()
})
