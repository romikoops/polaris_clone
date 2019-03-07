import * as React from 'react'
import { shallow } from 'enzyme'
import {
  firstAddress,
  contact,
  identity,
  theme
} from '../../../../../mocks/index'

import ContactSetterBodyNotifyeeContactsContactCard from '.'

const propsBase = {
  contactData: {
    firstAddress,
    contact
  },
  removeFunc: identity,
  theme
}

test('shallow render', () => {
  const Component = <ContactSetterBodyNotifyeeContactsContactCard {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})
