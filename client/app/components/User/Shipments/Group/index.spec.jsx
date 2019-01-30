import * as React from 'react'
import { shallow } from 'enzyme'
import {
  user, theme, identity, shipment
} from '../../../../mocks'

import UserShipmentsGroup from '.'

const propsBase = {
  handleShipmentAction: identity,
  hubHash: { foo: 'bar' },
  shipments: { foo: [shipment] },
  target: 'foo',
  theme,
  title: 'FOO_TITLE',
  user,
  userDispatch: {}
}

test('shallow render', () => {
  expect(shallow(<UserShipmentsGroup {...propsBase} />)).toMatchSnapshot()
})

test('shipments is falsy', () => {
  const props = {
    ...propsBase,
    shipments: null
  }
  expect(shallow(<UserShipmentsGroup {...props} />)).toMatchSnapshot()
})
