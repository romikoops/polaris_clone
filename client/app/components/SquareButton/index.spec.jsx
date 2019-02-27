import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { identity, theme } from '../../mocks/index'

import SquareButton from '.'

const propsBase = {
  active: false,
  back: false,
  disabled: false,
  handleDisabled: identity,
  handleNext: identity,
  icon: 'ICON',
  iconClass: 'ICON_CLASS',
  size: 'small',
  text: 'TEXT',
  theme
}

test('shallow render', () => {
  expect(shallow(<SquareButton {...propsBase} />)).toMatchSnapshot()
})

test('size is large', () => {
  const props = {
    ...propsBase,
    size: 'large'
  }
  expect(shallow(<SquareButton {...props} />)).toMatchSnapshot()
})

test('size is full', () => {
  const props = {
    ...propsBase,
    size: 'full'
  }
  expect(shallow(<SquareButton {...props} />)).toMatchSnapshot()
})

test('active is true', () => {
  const props = {
    ...propsBase,
    active: true
  }
  expect(shallow(<SquareButton {...props} />)).toMatchSnapshot()
})

test('handleNext is called', () => {
  const props = {
    ...propsBase,
    handleNext: jest.fn()
  }
  const wrapper = shallow(<SquareButton {...props} />)
  const button = wrapper.find('button').first()

  button.simulate('click')
  expect(props.handleNext).toHaveBeenCalled()
})

test('handleDisabled is called', () => {
  const props = {
    ...propsBase,
    disabled: true,
    handleDisabled: jest.fn()
  }
  const wrapper = shallow(<SquareButton {...props} />)
  const button = wrapper.find('button').first()

  button.simulate('click')
  expect(props.handleDisabled).toHaveBeenCalled()
})
