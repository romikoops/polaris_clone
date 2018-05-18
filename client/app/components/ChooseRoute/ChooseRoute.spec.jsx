import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, user, shipmentData, shipment } from '../../mocks'

/**
 * TODO
 * Better code coverage as recent change of `shipmentData.schedules`
 * require significant change of mock implementation
 */

jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('../RouteFilterBox/RouteFilterBox', () => ({
  // eslint-disable-next-line react/prop-types
  RouteFilterBox: ({ children }) => <div>{children}</div>
}))
jest.mock('../RouteResult/RouteResult', () => ({
  // eslint-disable-next-line react/prop-types
  RouteResult: ({ children }) => <div>{children}</div>
}))
jest.mock('../FlashMessages/FlashMessages', () => ({
  // eslint-disable-next-line react/prop-types
  FlashMessages: ({ children }) => <div>{children}</div>
}))
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ children }) => <div>{children}</div>
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <h2>{children}</h2>
}))
jest.mock('../NamedSelect/NamedSelect', () => ({
  // eslint-disable-next-line react/prop-types
  NamedSelect: ({ children }) => <div>{children}</div>
}))
jest.mock('../../constants', () => ({
  // eslint-disable-next-line react/prop-types
  currencyOptions: { fooKey: 'FOO_CURRENCY_OPTIONS' }
}))
// eslint-disable-next-line
import { ChooseRoute } from './ChooseRoute'

const tenant = {
  data: {
    scope: {
      modes_of_transport: {}
    }
  }
}

const editedShipmentData = {
  ...shipmentData,
  schedules: []
}

const propsBase = {
  theme,
  user,
  tenant,
  shipmentData: editedShipmentData,
  chooseRoute: identity,
  messages: [],
  req: {},
  setStage: identity,
  prevRequest: {
    shipment
  },
  shipmentDispatch: {
    goTo: identity
  }
}

test('shallow render', () => {
  expect(shallow(<ChooseRoute {...propsBase} />)).toMatchSnapshot()
})

test('shipmentData is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: null
  }
  expect(shallow(<ChooseRoute {...props} />)).toMatchSnapshot()
})

test('shipmentData.schedules is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: {
      ...shipmentData,
      schedules: null
    }
  }
  expect(shallow(<ChooseRoute {...props} />)).toMatchSnapshot()
})

test('messages.length > 0', () => {
  const props = {
    ...propsBase,
    messages: ['FOO_MESSAGE']
  }
  expect(shallow(<ChooseRoute {...props} />)).toMatchSnapshot()
})

test('user.guest is true', () => {
  const props = {
    ...propsBase,
    user: {
      ...user,
      guest: true
    }
  }
  expect(shallow(<ChooseRoute {...props} />)).toMatchSnapshot()
})
