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
import BestRoutesBox from './BestRoutesBox'

const propsBase = {
  chooseResult: identity,
  shipmentData,
  theme,
  user
}

test('shallow render', () => {
  expect(shallow(<BestRoutesBox {...propsBase} />)).toMatchSnapshot()
})

/**
 * Three cases as `chooseResult` is used in three places
 */
test('chooseResult is called | case 0', () => {
  const props = {
    ...propsBase,
    chooseResult: jest.fn()
  }
  const wrapper = mount(<BestRoutesBox {...props} />)
  const clickableDiv = wrapper.find('.best_card').first()
  clickableDiv.simulate('click')

  expect(props.chooseResult).toHaveBeenCalled()
})

test('chooseResult is called | case 1', () => {
  const props = {
    ...propsBase,
    chooseResult: jest.fn()
  }
  const wrapper = mount(<BestRoutesBox {...props} />)
  const clickableDiv = wrapper.find('.best_card').at(1)
  clickableDiv.simulate('click')

  expect(props.chooseResult).toHaveBeenCalled()
})

test('chooseResult is called | case 2', () => {
  const props = {
    ...propsBase,
    chooseResult: jest.fn()
  }
  const wrapper = mount(<BestRoutesBox {...props} />)
  const clickableDiv = wrapper.find('.best_card').last()
  clickableDiv.simulate('click')

  expect(props.chooseResult).toHaveBeenCalled()
})
