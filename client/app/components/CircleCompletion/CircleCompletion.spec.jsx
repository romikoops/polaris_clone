import * as React from 'react'
import { shallow } from 'enzyme'
import CircleCompletion from './CircleCompletion'

const propsBase = {
  icon: 'ICON',
  optionalText: 'OPTIONAL_TEXT',
  animated: false,
  size: '100px',
  margin: '2rem',
  opacity: 1
}

test('shallow render', () => {
  expect(shallow(<CircleCompletion {...propsBase} />)).toMatchSnapshot()
})

test('animated is true', () => {
  const props = {
    ...propsBase,
    animated: true
  }
  expect(shallow(<CircleCompletion {...props} />)).toMatchSnapshot()
})
