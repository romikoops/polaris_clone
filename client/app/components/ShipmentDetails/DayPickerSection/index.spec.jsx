import * as React from 'react'
import { shallow } from 'enzyme'
import DayPickerSection from '.'
import {
  selectedDay,
  scope,
  tenant,
  lastAvailableDate,
  theme
} from '../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const shipmentBase = {
  selectedDay,
  incoterm: {},
  preCarriage: false,
  onCarriage: false,
  direction: 'export'
}

const propsBase = {
  tenant,
  scope,
  shipment: shipmentBase,
  lastAvailableDate,
  theme
}

test('with empty props', () => {
  expect(() => shallow(<DayPickerSection />)).toThrow()
})

test('happy path', () => {
  expect(shallow(<DayPickerSection {...propsBase} />)).toMatchSnapshot()
})

test('selected day is falsy', () => {
  const props = {
    ...propsBase,
    shipment: {
      ...shipmentBase,
      selectedDay: null
    }
  }
  expect(shallow(<DayPickerSection {...props} />)).toMatchSnapshot()
})

test('pre carriage is true', () => {
  const props = {
    ...propsBase,
    shipment: {
      ...shipmentBase,
      preCarriage: true
    }
  }
  expect(shallow(<DayPickerSection {...props} />)).toMatchSnapshot()
})
