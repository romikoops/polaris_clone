import * as React from 'react'
import { shallow } from 'enzyme'
import { Price } from './Price'
import { user } from '../../mocks/index'

const propsBase = {
  value: 123.55,
  scale: '27',
  user
}

test('shallow rendering', () => {
  expect(shallow(<Price {...propsBase} />)).toMatchSnapshot()
})

test('scale is falsy', () => {
  const props = {
    ...propsBase,
    scale: null
  }
  expect(shallow(<Price {...props} />)).toMatchSnapshot()
})
