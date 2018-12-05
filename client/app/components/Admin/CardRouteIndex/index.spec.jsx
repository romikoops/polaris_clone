import * as React from 'react'
import { shallow } from 'enzyme'

import { theme, identity } from '../../../mocks'
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
  }
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

test('toggleNew && scope.show_beta_features', () => {
  const props = {
    ...propsBase,
    toggleNew: true,
    scope: { show_beta_features: true }
  }
  expect(shallow(<CardRoutesIndex {...props} />)).toMatchSnapshot()
})
