import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, user, identity, tenant } from '../../mocks'

jest.mock('../Header/Header', () => ({ children }) => <header>{children}</header>)

import ButtonSection from './ButtonSection'

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
  tenant: editedTenant,
  theme,
  user
}

test('user.role_id is 2', () => {
  const props = {
    ...propsBase,
    user: { ...user, role_id: 2 }
  }

  expect(shallow(<ButtonSection {...props} />)).toMatchSnapshot()
})

test('user.role_id is 1', () => {
  const props = {
    ...propsBase,
    user: { ...user, role_id: 2 }
  }

  expect(shallow(<ButtonSection {...props} />)).toMatchSnapshot()
})

test('is hidden', () => {
  const props = {
    ...propsBase,
    hidden: true
  }

  expect(shallow(<ButtonSection {...props} />)).toMatchSnapshot()
})
