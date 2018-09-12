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
    scope: {
      ...tenant.scope,
      closed_quotation_tool: true
    },
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

test('props.toAdmin is called', () => {
  const props = {
    ...propsBase,
    user: {
      ...user,
      role: {
        name: 'admin'
      }
    },
    toAdmin: jest.fn()
  }
  const wrapper = mount(<LandingTop {...props} />)
  const selector = 'div[className="layout-row flex-50"] button'
  const button = wrapper.find(selector).first()

  expect(props.toAdmin).not.toHaveBeenCalled()
  button.simulate('click')
  expect(props.toAdmin).toHaveBeenCalled()
})

test('props.goTo is called', () => {
  const props = {
    ...propsBase,
    user: {
      ...user,
      role: {
        name: 'shipper'
      }
    },
    goTo: jest.fn()
  }
  const wrapper = mount(<LandingTop {...props} />)
  const selector = 'div[className="layout-row flex-50"] button'
  const button = wrapper.find(selector).last()

  expect(props.goTo).not.toHaveBeenCalled()
  button.simulate('click')
  expect(props.goTo).toHaveBeenCalled()
})
