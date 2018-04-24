import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, clients, identity } from '../../../../mocks'
import { UserShipmentsGroup } from './'

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

/**
 * props.shipment should be array of `shipment` object but
 * shipments[target].map leads to other conclusion
 */
test('shallow render', () => {
  expect(shallow(<UserShipmentsGroup {...propsBase} />)).toMatchSnapshot()
})
