import * as React from 'react'
import { shallow } from 'enzyme'
import { UserMergedShipHeaders } from './UserMergedShipHeaders'

const propsBase = {
  title: 'FOO',
  total: 100
}

test('shallow render', () => {
  expect(shallow(<UserMergedShipHeaders {...propsBase} />)).toMatchSnapshot()
})
