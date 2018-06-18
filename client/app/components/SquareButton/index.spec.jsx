import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { identity, theme } from '../../mocks'

import SquareButton from './'

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

const createWrapper = propsInput => mount(<SquareButton {...propsInput} />)
const createShallow = propsInput => shallow(<SquareButton {...propsInput} />)

test('button click calls props.handleNext', () => {
  const props = {
    ...propsBase,
    handleNext: jest.fn()
  }
  const dom = createWrapper(props)
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
  const dom = createWrapper(props)
  const button = dom.find('button').first()

  button.simulate('click')
  expect(props.handleDisabled).toHaveBeenCalled()
})

test('shallow rendering when props.size is small', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})

test('shallow rendering when props.size is large', () => {
  const props = {
    ...propsBase,
    size: 'large'
  }

  expect(createShallow(props)).toMatchSnapshot()
})

test('shallow rendering when props.size is full', () => {
  const props = {
    ...propsBase,
    size: 'full'
  }

  expect(createShallow(props)).toMatchSnapshot()
})
