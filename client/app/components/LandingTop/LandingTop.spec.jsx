import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, user, identity, tenant } from '../../mocks'

jest.mock('../Header/Header', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <header>{children}</header>)

jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ children }) => <button>{children}</button>
}))
// eslint-disable-next-line
import { LandingTop } from './LandingTop'

const edittedTenant = {
  data: {
    ...tenant,
    name: 'FOO_NAME'
  }
}

const propsBase = {
  bookNow: identity,
  goTo: identity,
  toggleShowLogin: identity,
  tenant: edittedTenant,
  theme,
  toAdmin: identity,
  user: {
    ...user,
    role_id: 2
  }
}

const createWrapper = propsInput => mount(<LandingTop {...propsInput} />)

test.skip('user.role_id is 2', () => {
  expect(shallow(<LandingTop {...propsBase} />)).toMatchSnapshot()
})

test.skip('theme has truthy properties', () => {
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

test.skip('user.role_id is 1', () => {
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
      guest: true
    },
    toggleShowLogin: jest.fn()
  }
  const wrapper = createWrapper(props)

  const link = wrapper.find('a').first()

  link.simulate('click')
  expect(props.toggleShowLogin).toHaveBeenCalled()
})
