import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, tenant } from '../../../../mock'

import AdminCurrencyCenter from '.'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
const currenciesBase = [
  { key: 'FOO', rate: 1 },
  { key: 'BAR', rate: 0.5 },
  { key: 'BAZ', rate: 2 }
]

const propsBase = {
  theme,
  tenant,
  setCurrentUrl: identity,
  currencies: currenciesBase,
  appDispatch: {
    fetchCurrenciesForBase: identity
  }
}

test('shallow render', () => {
  expect(shallow(<AdminCurrencyCenter {...propsBase} />)).toMatchSnapshot()
})

test('currencies is falsy', () => {
  const props = {
    ...propsBase,
    currencies: []
  }
  expect(shallow(<AdminCurrencyCenter {...props} />)).toMatchSnapshot()
})

test('state.editBool is true', () => {
  const wrapper = shallow(<AdminCurrencyCenter {...propsBase} />)
  wrapper.setState({ editBool: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.rateBool is false', () => {
  const wrapper = shallow(<AdminCurrencyCenter {...propsBase} />)
  wrapper.setState({ rateBool: false })

  expect(wrapper).toMatchSnapshot()
})
