import * as React from 'react'
import { mount } from 'enzyme'
import { theme, user } from '../../mocks'

import FloatingMenu from './FloatingMenu'

const propsBase = {
  // eslint-disable-next-line react/prop-types
  Comp: ({ children }) => <div>{children}</div>,
  theme,
  user
}

let wrapper

const createWrapper = propsInput => mount(<FloatingMenu {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('click changes state.expand', () => {
  const clickableDiv = wrapper.find('.collapse_prompt').first()

  expect(wrapper.state().expand).toBeFalsy()
  clickableDiv.simulate('click')
  expect(wrapper.state().expand).toBeTruthy()
})
