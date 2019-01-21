import * as React from 'react'
import { shallow } from 'enzyme'
import Autocomplete from '.'
import {
  scope,
  theme
} from '../../mocks'

const propsBase = {
  theme,
  scope,
  target: 'TARGET'
}

test('with empty props', () => {
  expect(() => shallow(<Autocomplete />)).toThrow()
})

test('happy path', () => {
  expect(shallow(<Autocomplete {...propsBase} />)).toMatchSnapshot()
})
