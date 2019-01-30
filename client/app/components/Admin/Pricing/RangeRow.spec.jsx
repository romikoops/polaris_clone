import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mock'

import PricingRangeRow from './RangeRow'

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
  saveEdit: identity,
  handleSelect: identity,
  handleChange: identity,
  handleRangeChange: identity,
  handleDateEdit: identity,
  editCharge: {
    data: {
      FEE_KEY: {
        range: [
          {
            min: 'EDIT_CHARGE_MIN',
            max: 'EDIT_CHARGE_MAX',
            rate: 'EDIT_CHARGE_RATE'
          }
        ],
        rate: 'FEE_KEY_RATE',
        min: 'FEE_KEY_MIN',
        effective_date: 'EFF_DATE',
        expiration_date: 'EXP_DATE'
      }
    }
  },
  fee: {
    rate_basis: 'PER_SHIPMENT',
    key: 'FEE_KEY',
    range: [
      {
        min: 'MIN',
        max: 'MAX',
        rate: 'RATE'
      }
    ]
  },
  loadType: 'LOAD_TYPE',
  selectOptions: {
    LOAD_TYPE: {
      FEE_KEY: {
        rate_basis: 'RATE_BASIS'
      }
    }
  },
  target: '',
  isEditing: identity,
  initialEdit: false,
  theme
}

test('shallow render', () => {
  expect(shallow(<PricingRangeRow {...propsBase} />)).toMatchSnapshot()
})

test('state.edit is true', () => {
  const wrapper = shallow(<PricingRangeRow {...propsBase} />)
  wrapper.setState({ edit: true })

  expect(wrapper).toMatchSnapshot()
})

test('selectOptions is falsy', () => {
  const props = {
    ...propsBase,
    selectOptions: null
  }
  expect(shallow(<PricingRangeRow {...props} />)).toMatchSnapshot()
})
