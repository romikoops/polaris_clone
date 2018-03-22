import * as React from 'react'
import { mount } from 'enzyme'
import { CardLink } from './CardLink'

import {
  theme,
  identity
} from '../../mocks'

const propsBase = {
  text: 'FOO_TEXT',
  img: 'FOO_IMAGE',
  theme,
  path: 'FOO_PATH',
  selectedType: 'FOO_TYPE',
  code: 'BAR',
  handleClick: identity,
  options: {
    contained: true
  }
}

test('text content of component is based on props.text', () => {
  const wrapper = mount(<CardLink {...propsBase} />)

  expect(wrapper.text()).toBe(`${propsBase.text} `)
})
