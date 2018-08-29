import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, shipmentData, user, identity } from '../../mocks'

jest.mock('../../helpers', () => ({
  switchIcon: x => x,
  totalPrice: x => x,
  priceSpacing: x => x,
}))
jest.mock('../../constants', () => {
  const format = () => 19

  const moment = () => ({
    format
  })

  return { moment }
})
jest.mock('../Tooltip/Tooltip', () => ({
  // eslint-disable-next-line react/prop-types
  Tooltip: ({ props }) => <div {...props} />
}))

// eslint-disable-next-line
import { MessageShipmentData } from './MessageShipmentData'

const editedShipment = {
  ...shipmentData.shipment,
  origin_hub: { name: 'FOO_ORIGIN_HUB' },
  destination_hub: { name: 'FOO_DESTINATION_HUB' }
}
const editedShipmentData = {
  ...shipmentData,
  shipment: editedShipment,
  hubs: {
    startHub: 'FOO_START_HUB',
    endHub: 'FOO_END_HUB'
  }
}

const propsBase = {
  theme,
  name: 'FOO',
  onChange: identity,
  shipmentData: editedShipmentData,
  closeInfo: identity,
  user,
  pickupDate: 11
}

test('shallow render', () => {
  expect(shallow(<MessageShipmentData {...propsBase} />)).toMatchSnapshot()
})

test.skip('props.closeInfo is called', () => {
  const props = {
    ...propsBase,
    closeInfo: jest.fn()
  }
  const wrapper = mount(<MessageShipmentData {...props} />)
  const selector = 'div[className="flex-33 layout-row layout-align-space-around-center"]'

  const clickableDiv = wrapper.find(selector).last()

  clickableDiv.simulate('click')
  expect(props.closeInfo).toHaveBeenCalled()
})
