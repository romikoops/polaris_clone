import * as React from 'react'
import { shallow } from 'enzyme'
import Contact from './Contact'
import { user } from '../../mocks'

const propsBase = {
  contact: { data: user },
  contactType: '',
  textStyle: {}
}

test('shallow render', () => {
  expect(shallow(<Contact {...propsBase} />)).toMatchSnapshot()
})
