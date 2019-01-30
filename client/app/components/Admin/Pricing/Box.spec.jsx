import '../../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mock'

import AdminPricingBox from './Box'

const propsBase = {
  closeView: identity,
  charges: [{
    transport_category: 'TRANSPORT',
    pricing: {
      data: {
        foo: { range: true },
        bar: {}
      }
    }
  }],
  serviceLevels: [],
  title: 'TITLE',
  adminDispatch: {},
  theme
}

test('shallow render', () => {
  expect(shallow(<AdminPricingBox {...propsBase} />)).toMatchSnapshot()
})

test('charges is falsy', () => {
  const props = {
    ...propsBase,
    charges: null
  }
  expect(shallow(<AdminPricingBox {...props} />)).toMatchSnapshot()
})

test('title is falsy', () => {
  const props = {
    ...propsBase,
    title: null
  }
  expect(shallow(<AdminPricingBox {...props} />)).toMatchSnapshot()
})
