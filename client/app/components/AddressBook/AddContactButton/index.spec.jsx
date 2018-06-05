import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../../mocks'

jest.mock('uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
// eslint-disable-next-line import/first
import AddressBookAddContactButton from './'

const propsBase = {
  addContact: identity
}

test('shallow render', () => {
  expect(shallow(<AddressBookAddContactButton {...propsBase} />)).toMatchSnapshot()
})
