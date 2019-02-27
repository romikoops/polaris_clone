import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks/index'

import ContactSetter from './ContactSetter'

const propsBase = {
  theme,
  contacts: [],
  userLocations: [],
  shipper: {},
  consignee: {},
  notifyees: [],
  direction: 'FOO_DIRECTION',
  finishBookingAttempted: false,
  setContact: identity,
  removeNotifyee: identity
}

test('shallow render', () => {
  expect(shallow(<ContactSetter {...propsBase} />)).toMatchSnapshot()
})

test('props.direction === export', () => {
  const props = {
    ...propsBase,
    direction: 'export'
  }
  expect(shallow(<ContactSetter {...props} />)).toMatchSnapshot()
})

test('state.showModal is true', () => {
  const wrapper = shallow(<ContactSetter {...propsBase} />)
  wrapper.setState({ showModal: true })

  expect(wrapper).toMatchSnapshot()
})
