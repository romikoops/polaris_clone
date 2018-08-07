import * as React from 'react'
import { shallow, mount } from 'enzyme'

import { theme, identity } from '../../mocks'

import ConsentButton from './ConsentButton'

const propsBase = {
  theme,
  test: 'accept',
  disabled: false,
  active: false,
  handleNext: identity,
  handleDisabled: identity
}

test('handleNext is called', () => {
  const props = {
    ...propsBase,
    handleNext: jest.fn()
  }
  const wrapper = mount(<ConsentButton {...props} />)
  const button = wrapper.find('button').first()
  button.simulate('click')

  expect(props.handleNext).toHaveBeenCalled()
})

test('text is accept', () => {
  expect(shallow(<ConsentButton {...propsBase} />)).toMatchSnapshot()
})

test('text is decline', () => {
  const props = {
    ...propsBase,
    text: 'decline'
  }
  expect(shallow(<ConsentButton {...props} />)).toMatchSnapshot()
})

test('text is `ok, accept`', () => {
  const props = {
    ...propsBase,
    text: 'ok, accept'
  }
  expect(shallow(<ConsentButton {...props} />)).toMatchSnapshot()
})

test('text is cookies policy', () => {
  const props = {
    ...propsBase,
    text: 'cookies policy'
  }
  expect(shallow(<ConsentButton {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<ConsentButton {...props} />)).toMatchSnapshot()
})

test('active is true', () => {
  const props = {
    ...propsBase,
    active: true
  }
  expect(shallow(<ConsentButton {...props} />)).toMatchSnapshot()
})

test('disabled is true', () => {
  const props = {
    ...propsBase,
    disabled: true
  }
  expect(shallow(<ConsentButton {...props} />)).toMatchSnapshot()
})
