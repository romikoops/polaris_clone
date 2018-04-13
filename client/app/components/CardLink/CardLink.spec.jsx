import * as React from 'react'
import { mount, shallow } from 'enzyme'
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

test('props.handleClick is called', () => {
  const props = {
    ...propsBase,
    path: undefined,
    handleClick: jest.fn()
  }
  const wrapper = mount(<CardLink {...props} />)

  const clickableDiv = wrapper.find('.card_link').first()

  expect(props.handleClick).not.toHaveBeenCalled()
  clickableDiv.simulate('click')
  expect(props.handleClick).toHaveBeenCalled()
})

test('shallow render', () => {
  expect(shallow(<CardLink {...propsBase} />)).toMatchSnapshot()
})
