import * as React from 'react'
import { shallow } from 'enzyme'
import Contact from './Contact'
import { contact, turnFalsy, change } from '../../mocks'

const propsBase = {
  contact,
  contactType: '',
  textStyle: {}
}

test('shallow render', () => {
  expect(shallow(<Contact {...propsBase} />)).toMatchSnapshot()
})

test('contact.address is falsy', () => {
  const props = turnFalsy(
    propsBase,
    'contact.address'
  )
  expect(shallow(<Contact {...props} />)).toMatchSnapshot()
})

test('street_number and street are false', () => {
  const props = change(
    propsBase,
    'contact.address',
    {}
  )
  expect(shallow(<Contact {...props} />)).toMatchSnapshot()
})
