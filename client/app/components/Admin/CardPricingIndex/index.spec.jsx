import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'
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
  mot: 'ocean'
}

test('shallow render', () => {
  expect(shallow(<CardPricingIndex {...propsBase} />)).toMatchSnapshot()
})

test('scope has show_beta_features', () => {
  const props = {
    ...propsBase,
    scope: {
      show_beta_features: true
    }
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
