import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub, internalUser, user } from '../../../mocks/index'

import AdminHubsIndex from './AdminHubsIndex'

const propsBase = {
  theme,
  hubs: [hub],
  scope: {},
  viewHub: identity,
  toggleNewHub: identity,
  documentDispatch: {
    closeViewer: identity,
    uploadHubs: identity
  },
  user
}

test('shallow render', () => {
  expect(shallow(<AdminHubsIndex {...propsBase} />)).toMatchSnapshot()
})

test('hubs is falsy', () => {
  const props = {
    ...propsBase,
    hubs: null
  }
  expect(shallow(<AdminHubsIndex {...props} />)).toMatchSnapshot()
})

test('user.internal is truthy', () => {
  const props = {
    ...propsBase,
    user: internalUser
  }
  expect(shallow(<AdminHubsIndex {...props} />)).toMatchSnapshot()
})
