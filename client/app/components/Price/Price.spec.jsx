import * as React from 'react'
import { shallow as shallowMethod } from 'enzyme'
import { Price } from './Price'
import { user } from '../../mocks'

const propsBase = {
  value: 123.55,
  scale: '27',
  user
}

const createShallow = propsInput => shallowMethod(<Price {...propsInput} />)

test('shallow rendering', () => {
  const shallow = createShallow(propsBase)

  expect(shallow).toMatchSnapshot()
})
