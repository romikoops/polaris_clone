import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  identity, tenant, theme, user, change
} from '../../mocks'
import Header from './Header'

const propsBase = {
  appDispatch: identity,
  component: <div>FooComponent</div>,
  invert: false,
  loggingIn: false,
  loginAttempt: false,
  messageDispatch: {
    getUserConversations: identity
  },
  messages: [],
  noMessages: false,
  registering: false,
  req: null,
  scrollable: false,
  showRegistration: false,
  tenant,
  theme,
  unread: 0,
  user
}

test('shallow render', () => {
  expect(shallow(<Header {...propsBase} />)).toMatchSnapshot()
})

test('checkIsTop method', () => {
  const wrapper = shallow(<Header {...propsBase} />)
  wrapper.setState({ isTop: false })
  wrapper.instance().checkIsTop()

  expect(wrapper.state().isTop).toBe(true)
})

test('noMessages is true', () => {
  const props = {
    ...propsBase,
    noMessages: true
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('unread > 0', () => {
  const props = {
    ...propsBase,
    unread: 1
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('user.role_id === 2', () => {
  const props = {
    ...propsBase,
    user: {
      ...user,
      role_id: 2
    }
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('user is falsy', () => {
  const props = {
    ...propsBase,
    user: null
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('user && user.role && user.role.name.includes(admin)', () => {
  const props = change(
    propsBase,
    'user.role.name',
    'admin'
  )
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('showRegistration is true', () => {
  const props = {
    ...propsBase,
    showRegistration: true
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('tenant is falsy', () => {
  const props = {
    ...propsBase,
    tenant: {}
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('scrollable is true', () => {
  const props = {
    ...propsBase,
    scrollable: true
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('showModal is true', () => {
  const props = {
    ...propsBase,
    showModal: true
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('invert is true', () => {
  const props = {
    ...propsBase,
    invert: true
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('error && error[currentStage]', () => {
  const props = {
    ...propsBase,
    currentStage: 'foo',
    error: { foo: [{}] }
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('theme has logoWide', () => {
  const props = {
    ...propsBase,
    theme: {
      ...theme,
      logoWide: 'LOGO_WIDE'
    }
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})

test('theme has logoLarge', () => {
  const props = {
    ...propsBase,
    theme: {
      ...theme,
      logoLarge: 'LOGO_LARGE'
    }
  }
  expect(shallow(<Header {...props} />)).toMatchSnapshot()
})
