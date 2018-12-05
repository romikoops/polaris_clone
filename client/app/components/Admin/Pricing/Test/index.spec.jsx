import * as React from 'react'
import { shallow } from 'enzyme'

import {
  tenant,
  user,
  theme,
  identity
} from '../../../../mocks'

import AdminPricingTest from '.'

jest.mock('react-router-dom', () => ({
  withRouter: Component => Component
}))
jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const propsBase = {
  tenant,
  theme,
  user,
  bookingData: {},
  adminDispatch: {
    getPricingsTest: identity
  }
}

test('shallow render', () => {
  expect(shallow(<AdminPricingTest {...propsBase} />)).toMatchSnapshot()
})
