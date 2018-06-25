import * as React from 'react'
import { shallow } from 'enzyme'
import { Price } from './Price'
import { user } from '../../mocks'

const propsBase = {
  value: 123.55,
  scale: '27',
  user
}

test('shallow rendering', () => {
  expect(shallow(<Price {...propsBase} />)).toMatchSnapshot()
})
