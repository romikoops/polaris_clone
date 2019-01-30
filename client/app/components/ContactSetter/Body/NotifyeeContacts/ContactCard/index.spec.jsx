import * as React from 'react'
import { shallow } from 'enzyme'
import {
  address,
  contact,
  identity,
  theme
} from '../../../../../mocks'

import ContactSetterBodyNotifyeeContactsContactCard from '.'

const propsBase = {
  contactData: {
    address,
    contact
  },
  removeFunc: identity,
  theme
}

test('shallow render', () => {
  const Component = <ContactSetterBodyNotifyeeContactsContactCard {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})
