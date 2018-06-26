import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { identity, theme } from '../../mocks'
import { RoundButton } from './RoundButton'

const propsBase = {
  active: false,
  back: false,
  theme,
  icon: 'FOO_ICON',
  text: 'FOO_TEXT',
  iconClass: 'FOO_ICON_CLASS',
  size: 'small',
  handleNext: identity,
  handleDisabled: identity,
  disabled: false
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
