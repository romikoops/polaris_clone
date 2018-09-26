import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, shipment, locations } from '../../mocks'

import RouteHubBox from './RouteHubBox'

const editedShipment = {
  ...shipment,
  origin_hub: {
    startHub: { location: { } }
  },
  destination_hub: {
    startHub: { location: { } }
  }

}
const propsBase = {
  theme,
  shipment: editedShipment
}

test('shallow rendering', () => {
  expect(shallow(<RouteHubBox {...propsBase} />)).toMatchSnapshot()
})
