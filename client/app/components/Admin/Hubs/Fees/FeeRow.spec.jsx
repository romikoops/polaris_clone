import '../../../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../../mock'

import FeeRow from './FeeRow'

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
  target: '',
  saveEdit: identity,
  handleSelect: identity,
  handleChange: identity,
  handleDateEdit: identity,
  editCharge: {
    fees: {
      FEE_KEY: {}
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
  }
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
  expect(shallow(<FeeRow {...propsBase} />)).toMatchSnapshot()
})

test('state.confirm is true', () => {
  const wrapper = shallow(<FeeRow {...propsBase} />)
  wrapper.setState({ confirm: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.edit is true', () => {
  const wrapper = shallow(<FeeRow {...propsBase} />)
  wrapper.setState({ edit: true })

  expect(wrapper).toMatchSnapshot()
})

test('selectOptions is falsy', () => {
  const props = {
    ...propsBase,
    selectOptions: null
  }

  expect(shallow(<FeeRow {...props} />)).toMatchSnapshot()
})
