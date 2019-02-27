import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, identity } from '../../mocks/index'
import Checkbox from './Checkbox'

const propsBase = {
  checked: false,
  disabled: false,
  name: 'FOO_NAME',
  theme,
  size: '30px',
  onChange: identity,
  onClick: identity
}

const createWrapper = propsInput => mount(<Checkbox {...propsInput} />)

test('shallow render', () => {
  expect(shallow(<Checkbox {...propsBase} />)).toMatchSnapshot()
})

test('checked is true', () => {
  const props = {
    ...propsBase,
    checked: true
  }
  expect(shallow(<Checkbox {...props} />)).toMatchSnapshot()
})

test('disabled is true', () => {
  const props = {
    ...propsBase,
    disabled: true
  }
  expect(shallow(<Checkbox {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<Checkbox {...props} />)).toMatchSnapshot()
})

test('size is undefined', () => {
  const props = {
    ...propsBase,
    size: undefined
  }

  expect(shallow(<Checkbox {...props} />)).toMatchSnapshot()
})

test('click on div calls onClick', () => {
  const props = {
    ...propsBase,
    onClick: jest.fn()
  }
  const dom = createWrapper(props)
  const clickableDiv = dom.find('div').first()

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

  input.simulate('change', { target: { value: 'foo' } })
  expect(props.onChange).toHaveBeenCalled()
  expect(props.onChange.mock.calls).toHaveLength(1)
})
