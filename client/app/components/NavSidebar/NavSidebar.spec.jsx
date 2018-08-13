import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('../../components/Admin/AdminNavItem', () => {
  // eslint-disable-next-line react/prop-types
  const AdminNavItem = ({ children }) => <div>{children}</div>

  return { AdminNavItem }
})
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

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

test('shallow rendering', () => {
  expect(shallow(<NavSidebar {...propsBase} />)).toMatchSnapshot()
})
