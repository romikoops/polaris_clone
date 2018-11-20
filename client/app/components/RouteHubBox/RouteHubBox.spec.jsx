import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, shipment, addresses } from '../../mocks'

import RouteHubBox from './RouteHubBox'

const editedShipment = {
  ...shipment,
  origin_hub: {
    startHub: { address: { } }
  },
  destination_hub: {
    startHub: { address: { } }
  }

}
const propsBase = {
  theme,
  shipment: editedShipment
}

test('shallow rendering', () => {
  expect(shallow(<RouteHubBox {...propsBase} />)).toMatchSnapshot()
})
