import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, user, identity, tenant } from '../../mocks'

jest.mock('../Header/Header', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <header>{children}</header>)
// eslint-disable-next-line
import { LandingTop } from './LandingTop'

const editedTenant = {
  data: {
    ...tenant,
    name: 'FOO_NAME'
  }
}

const propsBase = {
  bookNow: identity,
  goTo: identity,
  toggleShowLogin: identity,
  tenant: editedTenant,
  theme,
  toAdmin: identity,
  user: {
    ...user,
    role_id: 2
  }
}

test('user.role_id is 2', () => {
  expect(shallow(<LandingTop {...propsBase} />)).toMatchSnapshot()
})

test('theme has truthy properties', () => {
  const editedTheme = {
    ...theme,
    background: 'green',
    logoLarge: 'FOO_LOGO_LARGE',
    logoWhite: 'FOO_LOGO_WHITE',
    welcome_text: 'FOO_WELCOME_TEXT'
  }
  const props = {
    ...propsBase,
    theme: editedTheme
  }
  expect(shallow(<LandingTop {...props} />)).toMatchSnapshot()
})

test('user.role_id is 1', () => {
  const props = {
    ...propsBase,
    user: {
      ...user,
      role_id: 1
    }
  }
  expect(shallow(<LandingTop {...props} />)).toMatchSnapshot()
})

test.skip('props.toggleShowLogin is called', () => {
  const props = {
    ...propsBase,
    user: {
      ...user,
      guest: true
    },
    toggleShowLogin: jest.fn()
  }
  const wrapper = mount(<LandingTop {...props} />)
  const link = wrapper.find('a').first()
  link.simulate('click')

  expect(props.toggleShowLogin).toHaveBeenCalled()
})
