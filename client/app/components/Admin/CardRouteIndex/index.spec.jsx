import * as React from 'react'
import { shallow } from 'enzyme'

import { theme, identity, internalUser, user } from '../../../mocks'
import CardRoutesIndex from '.'

const propsBase = {
  theme,
  mot: 'ocean',
  hubs: [],
  itineraries: [],
  scope: {},
  limit: 9,
  toggleNew: false,
  handleClick: identity,
  newText: 'NEW_TEXT',
  sideMenuNodes: [
    <div>foo</div>,
    <div>bar</div>
  ],
  adminDispatch: {
    getClientPricings: identity,
    getRoutePricings: identity
  },
  user
}

test('shallow render', () => {
  expect(shallow(<CardRoutesIndex {...propsBase} />)).toMatchSnapshot()
})

test('scope is falsy', () => {
  const props = {
    ...propsBase,
    scope: null
  }
  expect(shallow(<CardRoutesIndex {...props} />)).toMatchSnapshot()
})

test('toggleNew && user is internal', () => {
  const props = {
    ...propsBase,
    toggleNew: true,
    user: internalUser
  }
  expect(shallow(<CardRoutesIndex {...props} />)).toMatchSnapshot()
})
