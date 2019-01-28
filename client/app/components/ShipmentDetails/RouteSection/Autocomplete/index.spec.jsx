import * as React from 'react'
import { shallow } from 'enzyme'
import Autocomplete from '.'
import {
  scope,
  theme
} from '../../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

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
