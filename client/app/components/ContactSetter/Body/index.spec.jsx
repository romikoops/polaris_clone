import * as React from 'react'
import { shallow } from 'enzyme'
import {
  consignee,
  identity,
  notifyees,
  shipper,
  theme
} from '../../../mocks'

import ShipmentContactsBox from '.'

const propsBase = {
  consignee,
  direction: 'export',
  notifyees,
  removeNotifyee: identity,
  setContactForEdit: identity,
  shipper,
  showAddressBook: identity,
  theme
}

test('shallow render', () => {
  expect(shallow(<ShipmentContactsBox {...propsBase} />)).toMatchSnapshot()
})
