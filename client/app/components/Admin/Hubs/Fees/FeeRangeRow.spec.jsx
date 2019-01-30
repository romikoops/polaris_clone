import '../../../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../../mock'

import FeeRangeRow from './FeeRangeRow'

jest.mock('../../../../helpers', () => ({
  gradientCSSGenerator: x => x,
  gradientBorderGenerator: x => x
}))

const feeBase = {
  range: [{}],
  key: 'FEE_KEY',
  name: 'FEE_NAME'
}

const propsBase = {
  theme,
  target: 'port',
  saveEdit: identity,
  handleSelect: identity,
  handleChange: identity,
  handleRangeChange: identity,
  handleDateEdit: identity,
  editCharge: {
    fees: {
      FEE_KEY: {
        range: [[]]
      }
    }
  },
  direction: 'port',
  fee: feeBase,
  selectOptions: {
    port: {
      FEE_KEY: {
        rate_basis: 'RATE_BASIS'
      }
    }
  },
  isEditing: identity,
  initialEdit: false
}

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

test('shallow render', () => {
  expect(shallow(<FeeRangeRow {...propsBase} />)).toMatchSnapshot()
})

test('initialEdit is falsy', () => {
  const props = {
    ...propsBase,
    initialEdit: true
  }

  expect(shallow(<FeeRangeRow {...props} />)).toMatchSnapshot()
})

test('selectOptions is falsy', () => {
  const props = {
    ...propsBase,
    selectOptions: null
  }

  expect(shallow(<FeeRangeRow {...props} />)).toMatchSnapshot()
})

test('state.confirm is true', () => {
  const wrapper = shallow(<FeeRangeRow {...propsBase} />)
  wrapper.setState({ confirm: true })

  expect(wrapper).toMatchSnapshot()
})
