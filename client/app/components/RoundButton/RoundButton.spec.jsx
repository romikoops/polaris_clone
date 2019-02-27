import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { identity, theme } from '../../mocks/index'
import { RoundButton } from './RoundButton'

const propsBase = {
  active: false,
  back: false,
  disabled: false,
  handleDisabled: identity,
  handleNext: identity,
  icon: 'ICON',
  iconClass: 'ICON_CLASS',
  inverse: false,
  size: 'small',
  text: 'TEXT',
  theme
}

test('button click calls props.handleNext', () => {
  const props = {
    ...propsBase,
    handleNext: jest.fn()
  }
  const dom = mount(<RoundButton {...props} />)
  const button = dom.find('button').first()
  button.simulate('click')

  expect(props.handleNext).toHaveBeenCalled()
})

test('button click calls props.handleDisabled', () => {
  const props = {
    ...propsBase,
    disabled: true,
    handleDisabled: jest.fn()
  }
  const dom = mount(<RoundButton {...props} />)
  const button = dom.find('button').first()
  button.simulate('click')

  expect(props.handleDisabled).toHaveBeenCalled()
})

test('inverse is true', () => {
  const props = {
    ...propsBase,
    inverse: true
  }
  expect(shallow(<RoundButton {...props} />)).toMatchSnapshot()
})

test('inverse and disabled are true', () => {
  const props = {
    ...propsBase,
    inverse: true,
    disabled: true
  }
  expect(shallow(<RoundButton {...props} />)).toMatchSnapshot()
})

test('size is large', () => {
  const props = {
    ...propsBase,
    size: 'large'
  }

  expect(shallow(<RoundButton {...props} />)).toMatchSnapshot()
})

test('size is full', () => {
  const props = {
    ...propsBase,
    size: 'full'
  }
  expect(shallow(<RoundButton {...props} />)).toMatchSnapshot()
})

test('size is small', () => {
  expect(shallow(<RoundButton {...propsBase} />)).toMatchSnapshot()
})
