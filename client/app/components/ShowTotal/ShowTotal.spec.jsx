import * as React from 'react'
import { shallow } from 'enzyme'

import ShowTotal from './ShowTotal'

test('when total is passed', () => {
  const total = {
    value: 500,
    currency: 'EUR'
  }
  const showTotal = shallow(<ShowTotal total={total} />)
  expect(showTotal).toMatchSnapshot()
  expect(showTotal.contains('500.00')).toBe(true)
  expect(showTotal.contains('EUR')).toBe(true)
})

test('when total is not passed', () => {
  const total = {}

  const showTotal = shallow(<ShowTotal total={total} />)
  expect(showTotal).toMatchSnapshot()
  expect(showTotal.contains('500.00')).toBe(false)
  expect(showTotal.contains('EUR')).toBe(false)
})
