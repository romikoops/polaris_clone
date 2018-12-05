import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../../mocks'

import AdminCustomsSetter from './'

jest.mock('../../../../helpers', () => ({
  gradientCSSGenerator: x => x,
  gradientBorderGenerator: x => x
}))
jest.mock('../../../../constants', () => {
  const format = () => 11
  const add = () => ({ format })

  const moment = () => ({
    format,
    add
  })

  return {
    chargeGlossary: x => x,
    rateBasises: x => x,
    customsFeeSchema: x => x,
    rateBasisSchema: x => x,
    moment
  }
})

const propsBase = {
  theme,
  charges: {},
  adminDispatch: {
    editCustomsFees: identity
  }
}

let originalDate
const constantDate = new Date('2017-06-13T04:41:20')
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

test('!dnrKeys.includes(chargeKey)', () => {
  const wrapper = shallow(<AdminCustomsSetter {...propsBase} />)
  wrapper.setState({
    charges: {
      import: {
        currency: { bar: 'FOO' }
      }
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('chargeKey === rate_basis', () => {
  const wrapper = shallow(<AdminCustomsSetter {...propsBase} />)
  wrapper.setState({
    charges: {
      import: {
        currency: { rate_basis: 'RATE_BASIS' }
      }
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('chargeKey === expiration_date', () => {
  const wrapper = shallow(<AdminCustomsSetter {...propsBase} />)
  wrapper.setState({
    charges: {
      import: {
        currency: { expiration_date: 'EXPIRATION_DATE' }
      }
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('chargeKey === currency', () => {
  const wrapper = shallow(<AdminCustomsSetter {...propsBase} />)
  wrapper.setState({
    selectOptions: { import: { currency: {} } },
    charges: {
      import: {
        currency: { currency: 'CURRENCY' }
      }
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('state.edit is true', () => {
  const wrapper = shallow(<AdminCustomsSetter {...propsBase} />)
  wrapper.setState({
    edit: true,
    selectOptions: { import: { currency: {} } },
    charges: {
      import: {
        currency: { currency: 'CURRENCY' }
      }
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('state.directionBool is true', () => {
  const wrapper = shallow(<AdminCustomsSetter {...propsBase} />)
  wrapper.setState({
    directionBool: true,
    selectOptions: { import: { currency: {} } },
    charges: {
      import: {
        currency: { currency: 'CURRENCY' }
      }
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('when scope is falsy', () => {
  const props = {
    ...propsBase,
    scope: null
  }
  expect(shallow(<AdminCustomsSetter {...props} />)).toMatchSnapshot()
})
