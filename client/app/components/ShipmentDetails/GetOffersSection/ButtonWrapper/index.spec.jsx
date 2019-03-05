import * as React from 'react'
import { shallow } from 'enzyme'
import ButtonWrapper from '.'
import { theme } from '../../mocks'

const propsBase = {
  show: 'SHOW',
  subTexts: ['FOO_SUB_TEXT', 'BAR_SUB_TEXT'],
  text: 'TEXT',
  active: true,
  disabled: false,
  type: 'TYPE',
  onClick: null,
  onClickDisabled: null,
  theme,
  iconClass: 'ICON_CLASS',
  back: null
}

test('with empty props', () => {
  expect(shallow(<ButtonWrapper />)).toMatchSnapshot()
})

test('renders correctly', () => {
  expect(shallow(<ButtonWrapper {...propsBase} />)).toMatchSnapshot()
})

test('sub texts is falsy', () => {
  const props = {
    ...propsBase,
    subTexts: []
  }
  expect(shallow(<ButtonWrapper {...props} />)).toMatchSnapshot()
})

test('show is falsy', () => {
  const props = {
    ...propsBase,
    show: ''
  }
  expect(shallow(<ButtonWrapper {...props} />)).toMatchSnapshot()
})
