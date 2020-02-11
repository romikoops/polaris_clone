import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme as themeMock, user as userMock, tenant as tenantMock } from '../../mocks/index'

import InsuranceSelection from './InsuranceSelection'

const propsBase = {
  theme: themeMock,
  user: userMock,
  tenant: tenantMock,
  t: (k) => k
}

test('shallow render', () => {
  const { t, tenant, user, theme } = propsBase

  expect(shallow(<InsuranceSelection t={t} tenant={tenant} user={user} theme={theme} />)).toMatchSnapshot()
})

describe('Custom Insurance Message', () => {
  let wrapper

  beforeEach(() => {
    const { t, tenant, user, theme } = propsBase
    const { scope } = tenant
    scope.insurance = {
      messages: {
        accept: 'nice acceptance message',
        decline: 'nice decline message'
      }
    }
    wrapper = shallow(<InsuranceSelection t={t} tenant={tenant} user={user} theme={theme} />)
  })

  test('should match snapshot', () => {
    expect(wrapper).toMatchSnapshot()
  })

  test('should render the custom message for approval', () => {
    expect(wrapper.text()).toContain('nice acceptance message')
  })

  test('should render the custom message for declination', () => {
    expect(wrapper.text()).toContain('nice decline message')
  })
})
