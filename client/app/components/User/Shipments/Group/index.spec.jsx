import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, clients, identity, shipment } from '../../../../mocks'
import { UserShipmentsGroup } from './'

/**
 * ISSUE
 * props.shipment should be array of `shipment` object but
 * shipments[target].map leads to other conclusion such as array of array of shipment
 */
const propsBase = {
  theme,
  title: 'FOO_TITLE',
  target: '0',
  shipments: [[]],
  user: clients,
  handleShipmentAction: identity,
  hubHash: { foo: 'bar' },
  userDispatch: {}
}

test.skip('shallow render', () => {
  expect(shallow(<UserShipmentsGroup {...propsBase} />)).toMatchSnapshot()
})

test('props.shipment is truthy', () => {
  const editedShipment = {
    ...shipment,
    schedule_set: [{ hub_route_key: 'foo-bar' }]
  }
  const props = {
    ...propsBase,
    shipments: [[editedShipment]]
  }
  expect(shallow(<UserShipmentsGroup {...props} />)).toMatchSnapshot()
})

test('props.hubHash is falsy', () => {
  const props = {
    ...propsBase,
    hubHash: false
  }
  expect(shallow(<UserShipmentsGroup {...props} />)).toMatchSnapshot()
})
