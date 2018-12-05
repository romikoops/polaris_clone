import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, tenant, identity } from '../../../../mocks'

import AdminCurrencySetter from '.'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
const currenciesBase = [
  { key: 'FOO', rate: 1 },
  { key: 'BAR', rate: 0.5 },
  { key: 'BAZ', rate: 2 }
]
const tenantTheme = {
  colors: {
    brightPrimary: '#fafafa',
    brightSecondary: '#f5f5f5'
  }
}
const editedTenant = {
  ...tenant,
  data: {
    theme: tenantTheme
  }
}

const propsBase = {
  theme,
  tenant: editedTenant,
  currencies: currenciesBase,
  appDispatch: {
    fetchCurrenciesForBase: identity
  }
}

test('shallow render', () => {
  expect(shallow(<AdminCurrencySetter {...propsBase} />)).toMatchSnapshot()
})

test('currencies is falsy', () => {
  const props = {
    ...propsBase,
    currencies: []
  }
  expect(shallow(<AdminCurrencySetter {...props} />)).toMatchSnapshot()
})
