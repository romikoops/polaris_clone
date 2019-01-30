import '../../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mock'

import AdminPricingDedicated from './Dedicated'

const propsBase = {
  charges: [{
    transport_category: 'TRANSPORT',
    pricing: {
      data: {
        foo: { range: true },
        bar: {}
      }
    }
  }],
  clients: [],
  adminDispatch: {},
  theme,
  backBtn: identity,
  closePricingView: identity,
  initialEdit: false
}

test('shallow render', () => {
  expect(shallow(<AdminPricingDedicated {...propsBase} />)).toMatchSnapshot()
})

test('charges is falsy', () => {
  const props = {
    ...propsBase,
    charges: null
  }
  expect(shallow(<AdminPricingDedicated {...props} />)).toMatchSnapshot()
})

test('state.setUsers is true', () => {
  const charge = {
    transport_category: {
      cargo_class: {}
    },
    pricing: {
      data: {}
    }
  }
  const wrapper = shallow(<AdminPricingDedicated {...propsBase} />)

  wrapper.setState({ setUsers: true, charges: [charge] })

  expect(wrapper).toMatchSnapshot()
})

test('state.setUsers is false', () => {
  const charge = {
    transport_category: {
      cargo_class: {}
    },
    pricing: {
      data: {}
    }
  }
  const wrapper = shallow(<AdminPricingDedicated {...propsBase} />)

  wrapper.setState({ setUsers: false, charges: [charge] })

  expect(wrapper).toMatchSnapshot()
})
