import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../../mocks'

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
  }
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

test('scope.show_beta_features is truthy', () => {
  const props = {
    ...propsBase,
    scope: {
      show_beta_features: true
    }
  }
  expect(shallow(<AdminHubsIndex {...props} />)).toMatchSnapshot()
})
