import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { theme, user } from '../../mocks'

import FloatingMenu from './FloatingMenu'

const propsBase = {
  Comp: ({ children }) => <div>{children}</div>,
  theme,
  user
}

test('shallow render', () => {
  expect(shallow(<FloatingMenu {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<FloatingMenu {...props} />)).toMatchSnapshot()
})

test('click changes state.expand', () => {
  const wrapper = mount(<FloatingMenu {...propsBase} />)
  const clickableDiv = wrapper.find('.collapse_prompt').first()

  expect(wrapper.state().expand).toBeFalsy()
  clickableDiv.simulate('click')
  expect(wrapper.state().expand).toBeTruthy()
})
