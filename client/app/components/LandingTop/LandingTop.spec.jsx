import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, user, identity, tenant } from '../../mocks'

jest.mock('../Header/Header', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <header>{children}</header>)

jest.mock('../RoundButton/RoundButton', () => {
  // eslint-disable-next-line react/prop-types
  const RoundButton = ({ children }) => <button>{children}</button>

  return { RoundButton }
})

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

test('user.role_id is 2', () => {
  expect(shallow(<LandingTop {...propsBase} />)).toMatchSnapshot()
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

test('props.toggleShowLogin is called', () => {
  const props = {
    ...propsBase,
    user: {
      guest: true
    },
    toggleShowLogin: jest.fn()
  }
  const wrapper = createWrapper(props)

  const link = wrapper.find('a').first()

  expect(props.toggleShowLogin).not.toHaveBeenCalled()
  link.simulate('click')
  expect(props.toggleShowLogin).toHaveBeenCalled()
})
