import * as React from 'react'
import { shallow } from 'enzyme'
import GenericError from './Generic'
import { theme } from '../../mocks'

const propsBase = {
  theme,
  children: {}
}

test('shallow render', () => {
  expect(shallow(<GenericError {...propsBase} />)).toMatchSnapshot()
})
