import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'

import PricingRow from './Row'

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
  target: 'TARGET',
  direction: 'DIRECTION',
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
            max: 'EDIT_CHARGE_MAX',
            min: 'EDIT_CHARGE_MIN',
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
  isEditing: identity,
  initialEdit: false,
  theme
}

test('shallow render', () => {
  expect(shallow(<PricingRow {...propsBase} />)).toMatchSnapshot()
})

test('state.edit is true', () => {
  const wrapper = shallow(<PricingRow {...propsBase} />)
  wrapper.setState({ edit: true })

  expect(wrapper).toMatchSnapshot()
})

test('selectOptions is falsy', () => {
  const props = {
    ...propsBase,
    selectOptions: null
  }

  expect(shallow(<PricingRow {...props} />)).toMatchSnapshot()
})
