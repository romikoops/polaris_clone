import * as React from 'react'
import { mount, shallow } from 'enzyme'

import Button from './Button'

const propsBase = {
  text: 'FOO_TEXT'
}

test('it mounts only button HTML element', () => {
  const wrapper = mount(<Button {...propsBase} />)

  expect(wrapper.find('button')).toHaveLength(1)
  expect(wrapper.find('div')).toHaveLength(0)
})

test('it renders with spaces around props.text', () => {
  const wrapper = mount(<Button {...propsBase} />)

  expect(wrapper.text()).toEqual(` ${propsBase.text} `)
})

test('shallow render', () => {
  expect(shallow(<Button {...propsBase} />)).toMatchSnapshot()
})
