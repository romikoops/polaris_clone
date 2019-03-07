import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../../mocks/index'

import ContactSetterNewContactWrapper from '.'

const propsBase = {
  contactType: 'FOO',
  updateDimensions: identity,
  AddressBookProps: {},
  ShipmentContactFormProps: {}
}

test('shallow render', () => {
  expect(shallow(<ContactSetterNewContactWrapper {...propsBase} />)).toMatchSnapshot()
})

test('contactType === notifyee && compName === ShipmentContactForm', () => {
  const props = {
    ...propsBase,
    contactType: 'notifyee'
  }
  const wrapper = shallow(<ContactSetterNewContactWrapper {...props} />)
  wrapper.setState({ compName: 'ShipmentContactForm' })

  expect(wrapper).toMatchSnapshot()
})

test('compName !== AddressBook', () => {
  const wrapper = shallow(<ContactSetterNewContactWrapper {...propsBase} />)
  wrapper.setState({ compName: 'ShipmentContactForm' })

  expect(wrapper).toMatchSnapshot()
})
