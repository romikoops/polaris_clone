import * as React from 'react'
import { mount } from 'enzyme'
import { theme, identity } from '../../mocks'
import { Checkbox } from './Checkbox'

const propsBase = {
  checked: false,
  disabled: false,
  name: 'FOO_NAME',
  theme,
  size: '30px',
  onChange: identity,
  onClick: identity
}

let wrapper

const createWrapper = propsInput => mount(<Checkbox {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('click on div calls onClick', () => {
  const props = {
    ...propsBase,
    onClick: jest.fn()
  }
  const dom = createWrapper(props)
  const clickableDiv = dom.find('div').first()

  expect(props.onClick).not.toHaveBeenCalled()
  clickableDiv.simulate('click')
  expect(props.onClick).toHaveBeenCalled()
})

test('input action calls onChange', () => {
  const props = {
    ...propsBase,
    onChange: jest.fn()
  }
  const dom = createWrapper(props)
  const input = dom.find('input').first()

  expect(props.onChange).not.toHaveBeenCalled()
  input.simulate('change', { target: { value: 'foo' } })
  expect(props.onChange).toHaveBeenCalled()
  expect(props.onChange.mock.calls).toHaveLength(1)
})

test('when size is defined, it influence style', () => {
  const span = wrapper.find('span').first()
  const style = span.prop('style')

  expect(style).toEqual({
    height: propsBase.size,
    width: propsBase.size
  })
})

test('when size is not defined, style is empty', () => {
  const noSize = createWrapper({
    ...propsBase,
    size: undefined
  })
  const span = noSize.find('span').first()
  const style = span.prop('style')

  expect(style).toEqual({})
})
