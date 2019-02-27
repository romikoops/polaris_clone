import * as React from 'react'
import { shallow } from 'enzyme'
import {
  firstContact,
  hub,
  identity,
  match,
  shipment,
  theme,
  turnFalsy
} from '../../mocks/index'

import UserContactsView from './UserContactsView'

const contactData = {
  contact: firstContact,
  shipments: [shipment],
  address: identity
}

const propsBase = {
  theme,
  loading: false,
  match,
  hubs: [hub],
  contactData,
  userDispatch: {
    goBack: identity,
    getContact: identity
  }
}

test('shallow render', () => {
  expect(shallow(<UserContactsView {...propsBase} />)).toMatchSnapshot()
})

test('contactData is falsy', () => {
  const props = {
    ...propsBase,
    contactData: null
  }
  expect(shallow(<UserContactsView {...props} />)).toMatchSnapshot()
})

test('contactData.address is falsy', () => {
  const props = turnFalsy(
    propsBase,
    'contactData.address'
  )
  expect(shallow(<UserContactsView {...props} />)).toMatchSnapshot()
})

test('state.editBool is true', () => {
  const wrapper = shallow(<UserContactsView {...propsBase} />)
  wrapper.setState({ editBool: true })

  expect(wrapper).toMatchSnapshot()
})
