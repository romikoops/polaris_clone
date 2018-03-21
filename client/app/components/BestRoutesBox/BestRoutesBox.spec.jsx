import * as React from 'react'
import { mount, shallow } from 'enzyme'

jest.mock('../Price/Price', () => {
  const Price = () => <div />

  return {
    Price
  }
})
// eslint-disable-next-line import/first
import { BestRoutesBox } from './BestRoutesBox'

const propsBase = {
  user: {},
  chooseResult: () => {},
  shipmentData: {
    shipment: {},
    schedules: []
  }
}

test('text content', () => {
  const wrapper = mount(<BestRoutesBox {...propsBase} />)
  const expectedResult = 'Best DealCheapest RouteFastest route'

  expect(wrapper.text()).toBe(expectedResult)
})

test('shallow', () => {
  const wrapper = shallow(<BestRoutesBox {...propsBase} />)

  expect(wrapper).toMatchSnapshot()
})
