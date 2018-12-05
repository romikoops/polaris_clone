import * as React from 'react'
import { shallow } from 'enzyme'
import {
  shipmentData, theme, identity, change
} from '../../../mocks'
import AdminShipmentView from './AdminShipmentView'

jest.mock('moment', () => {
  const format = () => 19
  const subtract = () => ({ format })
  const add = () => ({ format })

  const moment = () => ({
    format,
    subtract,
    add
  })

  return moment
})
jest.mock('moment-range', () => ({
  extendMoment: x => x
}))

const propsBase = {
  theme,
  hubs: [],
  shipmentData,
  clients: [],
  handleShipmentAction: identity,
  loading: false,
  adminDispatch: {
    getShipment: identity
  },
  match: {},
  scope: {}
}

test('shallow render', () => {
  expect(shallow(<AdminShipmentView {...propsBase} />)).toMatchSnapshot()
})

test('service && service.total', () => {
  const props = change(
    propsBase,
    'shipmentData.shipment.selected_offer',
    { export: { total: 'EXPORT_TOTAL' } }
  )
  expect(shallow(<AdminShipmentView {...props} />)).toMatchSnapshot()
})
