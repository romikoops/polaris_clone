import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { theme, user } from '../../mocks'

import FloatingMenu from './FloatingMenu'

const propsBase = {
  // eslint-disable-next-line react/prop-types
  Comp: ({ children }) => <div>{children}</div>,
  theme,
  user
}

const createWrapper = propsInput => mount(<FloatingMenu {...propsInput} />)

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
  const wrapper = createWrapper(propsBase)
  const clickableDiv = wrapper.find('.collapse_prompt').first()

  expect(wrapper.state().expand).toBeFalsy()
  clickableDiv.simulate('click')
  expect(wrapper.state().expand).toBeTruthy()
})
