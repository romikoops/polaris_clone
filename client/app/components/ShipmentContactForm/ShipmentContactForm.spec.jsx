import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks/index'

import ShipmentContactForm from './ShipmentContactForm'

const propsBase = {
  theme,
  showEdit: false,
  contactType: 'notifyee'
}

test('shallow rendering', () => {
  expect(
    shallow(<ShipmentContactForm {...propsBase} />)
  ).toMatchSnapshot()
})

test('showEdit is true', () => {
  const props = {
    ...propsBase,
    showEdit: true
  }
  expect(
    shallow(<ShipmentContactForm {...props} />)
  ).toMatchSnapshot()
})

test('contactType !== notifyee', () => {
  const props = {
    ...propsBase,
    contactType: 'foo'
  }
  expect(
    shallow(<ShipmentContactForm {...props} />)
  ).toMatchSnapshot()
})
