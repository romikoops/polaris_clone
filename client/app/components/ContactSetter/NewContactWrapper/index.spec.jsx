import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../../mocks'
// eslint-disable-next-line
import ContactSetterNewContactWrapper from './'

const propsBase = {
  contactType: 'FOO',
  updateDimensions: identity,
  AddressBookProps: {},
  ShipmentContactFormProps: {}
}

test('shallow render', () => {
  expect(shallow(<ContactSetterNewContactWrapper {...propsBase} />)).toMatchSnapshot()
})

test('compName !== AddressBook', () => {
  const props = {
    ...propsBase
  }
  const wrapper = shallow(<ContactSetterNewContactWrapper {...props} />)
  wrapper.setState({ compName: 'ShipmentContactForm' })

  expect(wrapper).toMatchSnapshot()
})
