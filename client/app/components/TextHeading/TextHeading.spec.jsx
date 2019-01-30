import * as React from 'react'
import { shallow } from 'enzyme'
import TextHeading from './TextHeading'

const propsBase = {
  text: 'TEXT',
  size: 1,
  color: 'COLOR',
  Comp: ({ children }) => <div>{children}</div>
}

test('size is 1', () => {
  expect(shallow(<TextHeading {...propsBase} />)).toMatchSnapshot()
})

test('size is 2', () => {
  const props = {
    ...propsBase,
    size: 2
  }
  expect(shallow(<TextHeading {...props} />)).toMatchSnapshot()
})

test('size is 3', () => {
  const props = {
    ...propsBase,
    size: 3
  }
  expect(shallow(<TextHeading {...props} />)).toMatchSnapshot()
})

test('size is 4', () => {
  const props = {
    ...propsBase,
    size: 4
  }
  expect(shallow(<TextHeading {...props} />)).toMatchSnapshot()
})

test('size is greater than 4', () => {
  const props = {
    ...propsBase,
    size: 10
  }
  expect(shallow(<TextHeading {...props} />)).toMatchSnapshot()
})
