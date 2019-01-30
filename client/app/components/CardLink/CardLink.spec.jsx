import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

import CardLink from './CardLink'

const propsBase = {
  text: 'FOO_TEXT',
  img: 'FOO_IMAGE',
  theme,
  path: 'FOO_PATH',
  selectedType: 'FOO_TYPE',
  code: 'BAR',
  allowedCargoTypes: { BAR: true },
  handleClick: identity,
  options: {
    contained: true
  }
}

test('shallow render', () => {
  expect(shallow(<CardLink {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<CardLink {...props} />)).toMatchSnapshot()
})

test('code && selectedType === code', () => {
  const props = {
    ...propsBase,
    code: propsBase.selectedType
  }
  expect(shallow(<CardLink {...props} />)).toMatchSnapshot()
})

test('state.redirect is true', () => {
  const wrapper = shallow(<CardLink {...propsBase} />)
  wrapper.setState({ redirect: true })

  expect(wrapper).toMatchSnapshot()
})

test('handleClick is called', () => {
  const props = {
    ...propsBase,
    path: null,
    handleClick: jest.fn()
  }
  const wrapper = mount(<CardLink {...props} />)
  const clickableDiv = wrapper.find('.card_link').first()
  clickableDiv.simulate('click')

  expect(props.handleClick).toHaveBeenCalled()
})
