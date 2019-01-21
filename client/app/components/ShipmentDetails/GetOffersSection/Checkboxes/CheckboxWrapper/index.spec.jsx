import * as React from 'react'
import { shallow } from 'enzyme'
import CheckboxWrapper from '.'
import {
  identity,
  theme
} from '../../../mocks'

const propsBase = {
  id: 1,
  theme,
  name: 'NAME',
  className: 'CLASS_NAME',
  checked: true,
  labelContent: 'LABEL_CONTENT',
  onChange: identity,
  show: true,
  style: {}
}

test('with empty props', () => {
  expect(shallow(<CheckboxWrapper />)).toMatchSnapshot()
})

test('happy path', () => {
  expect(shallow(<CheckboxWrapper {...propsBase} />)).toMatchSnapshot()
})
