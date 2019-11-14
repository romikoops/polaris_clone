import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, user, identity, tenant
} from '../../mocks/index'

import Landing, { BasicLanding } from './Landing'

const propsBase = {
  bookNow: identity,
  goTo: identity,
  tenant,
  theme,
  toAdmin: identity,
  toggleShowLogin: identity,
  user,
  contentDispatch: {
    getContentForComponent: () => []
  }
}

test('shallow render', () => {
  expect(shallow(<Landing {...propsBase} />)).toMatchSnapshot()
})

describe('shouldShowLogin()', () => {
  it('shows the login for a closed shop and no user', () => {
    const props = {
      ...propsBase,
      tenant: {
        ...propsBase.tenant,
        scope: {
          ...propsBase.tenant.scope,
          closed_shop: true
        }
      },
      user: null
    }
    const wrapper = shallow(<BasicLanding {...props} />)
    expect(wrapper.instance().shouldShowLogin()).toEqual(true)
  })

  it('does not show the login for a open shop and no user', () => {
    const props = {
      ...propsBase,
      tenant: {
        ...propsBase.tenant,
        scope: {
          ...propsBase.tenant.scope,
          closed_shop: false
        }
      },
      user: null
    }
    const wrapper = shallow(<BasicLanding {...props} />)
    expect(wrapper.instance().shouldShowLogin()).toEqual(true)
  })

  it('shows the login for a closed shop and guest user', () => {
    const props = {
      ...propsBase,
      tenant: {
        ...propsBase.tenant,
        scope: {
          ...propsBase.tenant.scope,
          closed_shop: true
        }
      },
      user: {
        ...propsBase.user,
        guest: true
      },
      loggedIn: true
    }
    const wrapper = shallow(<BasicLanding {...props} />)
    expect(wrapper.instance().shouldShowLogin()).toEqual(true)
  })
})

