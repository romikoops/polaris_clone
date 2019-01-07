import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, internalUser } from '../../../mocks'
import CardPricingIndex from '.'

const propsBase = {
  theme,
  hubs: [],
  itineraries: [],
  toggleCreator: identity,
  allNumPages: {},
  adminDispatch: {
    getClientPricings: identity,
    getRoutePricings: identity
  },
  documentDispatch: {
    closeViewer: identity,
    uploadPricings: identity
  },
  scope: {},
  mot: 'ocean',
  user: internalUser
}

test('shallow render', () => {
  expect(shallow(<CardPricingIndex {...propsBase} />)).toMatchSnapshot()
})

test('user is internal', () => {
  const props = {
    ...propsBase,
    user: internalUser
  }
  expect(shallow(<CardPricingIndex {...props} />)).toMatchSnapshot()
})

test('scope is falsy', () => {
  const props = {
    ...propsBase,
    scope: null
  }
  expect(shallow(<CardPricingIndex {...props} />)).toMatchSnapshot()
})

test('state.page > 1', () => {
  const wrapper = shallow(<CardPricingIndex {...propsBase} />)
  wrapper.setState({ page: 2 })
  expect(wrapper).toMatchSnapshot()
})
