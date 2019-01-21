import * as React from 'react'
import { shallow } from 'enzyme'
import ButtonWrapper from '.'
import {
  identity,
  theme
} from '../../mocks'

const propsBase = {
  show: 'SHOW',
  subTexts: ['FOO_SUB_TEXT', 'BAR_SUB_TEXT'],
  text: 'TEXT',
  active: true,
  disabled: false,
  type: 'TYPE',
  onClick: identity,
  onClickDisabled: identity,
  theme,
  iconClass: 'ICON_CLASS',
  back: identity
}

test('with empty props', () => {
  expect(shallow(<ButtonWrapper />)).toMatchSnapshot()
})

test('happy path', () => {
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
