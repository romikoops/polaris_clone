import * as React from 'react'
import { mount } from 'enzyme'

import Button from './Button'

test('it mounts only button HTML element', () => {
  const props = {
    text: 'foo'
  }
  const wrapper = mount(<Button {...props} />)

  expect(wrapper.find('button')).toHaveLength(1)
  expect(wrapper.find('div')).toHaveLength(0)
})

test('it renders with spaces around props.text', () => {
  const props = {
    text: 'foo'
  }
  const wrapper = mount(<Button {...props} />)

  expect(wrapper.text()).toEqual(` ${props.text} `)
})
