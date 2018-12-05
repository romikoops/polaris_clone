import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, change } from '../../mocks'

import AdminPriceEditor from './AdminPriceEditor'

jest.mock('moment', () => {
  const format = () => 19
  const subtract = () => ({ format })
  const add = () => ({ format })

  const moment = () => ({
    format,
    subtract,
    add
  })

  return moment
})
jest.mock('moment-range', () => ({
  extendMoment: x => x
}))
jest.mock('react-day-picker/moment', () => ({
  formatDate: () => 'FORMAT_DATE',
  parseDate: () => 'PARSE_DATE'
}))

let originalDate
const constantDate = new Date('2017-06-13T04:41:20z')
beforeEach(() => {
  originalDate = Date
  // eslint-disable-next-line no-global-assign
  Date = class extends Date {
    constructor () {
      return constantDate
    }
  }
})

afterEach(() => {
  // eslint-disable-next-line no-global-assign
  Date = originalDate
})

const propsBase = {
  theme,
  closeEdit: identity,
  adminTools: {
    updatePricing: identity
  },
  pricing: {
    _id: 0,
    data: {}
  },
  hubRoute: {
    name: 'NAME'
  }
}

test('shallow render', () => {
  expect(shallow(<AdminPriceEditor {...propsBase} />)).toMatchSnapshot()
})

test('pricing.load_type is lcl', () => {
  const props = change(
    propsBase,
    'pricing',
    { load_type: 'lcl' }
  )
  expect(shallow(<AdminPriceEditor {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminPriceEditor {...props} />)).toMatchSnapshot()
})

test('chargeKey === rate_basis', () => {
  const props = change(
    propsBase,
    'pricing.data',
    { foo: { rate_basis: {} } }
  )

  expect(shallow(<AdminPriceEditor {...props} />)).toMatchSnapshot()
})

test('chargeKey === currency', () => {
  const props = change(
    propsBase,
    'pricing.data',
    { foo: { currency: {} } }
  )

  expect(shallow(<AdminPriceEditor {...props} />)).toMatchSnapshot()
})

test('chargeKey === range', () => {
  const props = change(
    propsBase,
    'pricing.data',
    { foo: { range: [] } }
  )

  expect(shallow(<AdminPriceEditor {...props} />)).toMatchSnapshot()
})

test('chargeKey !== currency', () => {
  const props = change(
    propsBase,
    'pricing.data',
    { foo: { bar: {} } }
  )

  expect(shallow(<AdminPriceEditor {...props} />)).toMatchSnapshot()
})

test('state.confirm is true', () => {
  const wrapper = shallow(<AdminPriceEditor {...propsBase} />)
  wrapper.setState({ confirm: true })

  expect(wrapper).toMatchSnapshot()
})
