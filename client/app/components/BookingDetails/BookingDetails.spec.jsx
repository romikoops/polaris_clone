import * as React from 'react'
import { shallow } from 'enzyme'

import {
  theme,
  shipment,
  shipmentData,
  identity,
  tenant,
  user
} from '../../mocks'

jest.mock('react-scroll', () => ({
  // eslint-disable-next-line react/prop-types
  default: ({ children }) => <div>{children}</div>
}))
jest.mock('formsy-react', () => ({
  // eslint-disable-next-line react/prop-types
  default: ({ children }) => <div>{children}</div>
}))
jest.mock('../CargoDetails/CargoDetails', () => ({
  // eslint-disable-next-line react/prop-types
  CargoDetails: ({ children }) => <div>{children}</div>
}))
jest.mock('../ContactSetter/ContactSetter', () => ({
  // eslint-disable-next-line react/prop-types
  ContactSetter: ({ children }) => <div>{children}</div>
}))
jest.mock('../RouteHubBox/RouteHubBox', () => ({
  // eslint-disable-next-line react/prop-types
  RouteHubBox: ({ children }) => <div>{children}</div>
}))
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ children }) => <button>{children}</button>
}))
// eslint-disable-next-line
import { BookingDetails } from './BookingDetails'

const edittedShipmentData = {
  ...shipmentData,
  hubs: {}
}

const propsBase = {
  theme,
  tenant,
  shipmentData: edittedShipmentData,
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

test('shallow render', () => {
  expect(shallow(<BookingDetails {...propsBase} />)).toMatchSnapshot()
})
