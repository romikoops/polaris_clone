import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, user, shipmentData, shipment } from '../../mocks'

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

const propsBase = {
  theme,
  user,
  shipmentData,
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
