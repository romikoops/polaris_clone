import * as React from 'react'
import { mount } from 'enzyme'

import {
  theme,
  shipment,
  shipmentData,
  identity,
  tenant,
  user
} from '../../mocks'

jest.mock('../CargoDetails/CargoDetails', () => ({
  // eslint-disable-next-line react/prop-types
  CargoDetails: ({ children }) => <div>{children}</div>
}))
jest.mock('../ContactSetter/ContactSetter', () => ({
  // eslint-disable-next-line react/prop-types
  ContactSetter: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line
import { BookingDetails } from './BookingDetails'

const propsBase = {
  theme,
  tenant,
  shipmentData,
  nextStage: identity,
  prevRequest: {
    shipment
  },
  setStage: identity,
  hideRegistration: identity,
  shipmentDispatch: {
    toDashboard: identity
  },
  currencies: [{
    key: 'USD',
    rate: 1.05
  }],
  user
}

test('CargoDetails component is called with user mock', () => {
  const wrapper = mount(<BookingDetails {...propsBase} />)
  const CargoDetails = wrapper.find('CargoDetails').first()

  expect(CargoDetails.prop('user')).toBe(user)
})
