import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, client, change
} from '../../mock'
import AdminPricingClientView from './AdminPricingClientView'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  theme,
  adminActions: {
    getClientPricings: identity
  },
  clientPricings: {
    client,
    userPricings: {}
  },
  loading: false,
  match: {},
  pricingData: {
    routes: [],
    pricings: [],
    hubRoutes: [],
    transportCategories: []
  }
}

test('shallow render', () => {
  expect(shallow(<AdminPricingClientView {...propsBase} />)).toMatchSnapshot()
})

test('pricingData is falsy', () => {
  const props = {
    ...propsBase,
    pricingData: null
  }
  expect(shallow(<AdminPricingClientView {...props} />)).toMatchSnapshot()
})

test('clientPricings.userPricings is truthy', () => {
  const props = change(
    propsBase,
    'clientPricings.userPricings',
    {
      foo: {
        itinerary: { name: 'ITINERARY_NAME' },
        pricings: [{
          transport_category: 'TRANSPORT_CATEGORY',
          pricing: 'TRANSPORT_PRICING'
        }]
      }
    }
  )
  expect(shallow(<AdminPricingClientView {...props} />)).toMatchSnapshot()
})

test('clientPricings.userPricings is falsy', () => {
  const props = change(
    propsBase,
    'clientPricings.userPricings',
    null
  )
  expect(shallow(<AdminPricingClientView {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminPricingClientView {...props} />)).toMatchSnapshot()
})

test('state.editorBool is true', () => {
  const wrapper = shallow(<AdminPricingClientView {...propsBase} />)
  wrapper.setState({ editorBool: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.confirm is true', () => {
  const wrapper = shallow(<AdminPricingClientView {...propsBase} />)
  wrapper.setState({ confirm: true })

  expect(wrapper).toMatchSnapshot()
})
