import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, theme } from '../../mocks'

jest.mock('../../helpers', () => ({
  switchIcon: x => x,
  capitalize: x => x.toUpperCase()
}))
jest.mock('../../constants', () => {
  const format = () => 19
  const add = () => ({ format })

  const moment = () => ({
    format,
    add
  })

  return { moment }
})
jest.mock('../ShipmentContainers/ShipmentContainers', () => ({
  // eslint-disable-next-line react/prop-types
  ShipmentContainers: ({ children }) => <div>{children}</div>
}))
jest.mock('../ShipmentCargoItems/ShipmentCargoItems', () => ({
  // eslint-disable-next-line react/prop-types
  ShipmentCargoItems: ({ children }) => <div>{children}</div>
}))
jest.mock('react-day-picker/DayPickerInput', () => ({
  // eslint-disable-next-line react/prop-types
  default: ({ children }) => <div>{children}</div>
}))
jest.mock('../Checkbox/Checkbox', () => ({
  // eslint-disable-next-line react/prop-types
  Checkbox: ({ children }) => <div>{children}</div>
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line import/first
import { RouteFilterBox } from './RouteFilterBox'

const propsBase = {
  departureDate: 0,
  theme,
  setDurationFilter: identity,
  setMoT: identity,
  setDepartureDate: identity,
  durationFilter: 1,
  pickup: true,
  shipment: {}
}

const createShallow = propsInput => shallow(<RouteFilterBox {...propsInput} />)

let originalDate

beforeEach(() => {
  // eslint-disable-next-line no-global-assign
  originalDate = Date
  // eslint-disable-next-line no-global-assign
  Date = () => 1462361249717
})

afterEach(() => {
  // eslint-disable-next-line no-global-assign
  Date = originalDate
})

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})

test('props.pickup is false', () => {
  const props = {
    ...propsBase,
    pickup: false
  }
  expect(createShallow(props)).toMatchSnapshot()
})
