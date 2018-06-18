import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { theme, identity, user, shipmentData } from '../../mocks'

jest.mock('../../helpers', () => ({
  gradientGenerator: x => x
}))
jest.mock('../../constants', () => {
  const moment = x => ({
    diff: y => x - y
  })

  return { moment }
})
// eslint-disable-next-line import/first
import { BestRoutesBox } from './BestRoutesBox'

const propsBase = {
  chooseResult: identity,
  shipmentData,
  theme,
  user
}

test('shallow render', () => {
  expect(shallow(<BestRoutesBox {...propsBase} />)).toMatchSnapshot()
})

test('chooseResult is called', () => {
  const props = {
    ...propsBase,
    chooseResult: jest.fn()
  }
  const wrapper = mount(<BestRoutesBox {...props} />)
  const clickableDiv = wrapper.find('.best_card').first()
  clickableDiv.simulate('click')

  expect(props.chooseResult).toHaveBeenCalled()
  expect(props.chooseResult).toHaveBeenCalledWith({ schedule: { hub_route_key: 'FOO_HUB_ROUTE_KEY' }, total: 7 })
})
