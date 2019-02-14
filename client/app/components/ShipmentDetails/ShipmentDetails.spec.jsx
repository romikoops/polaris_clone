import * as React from 'react'
import { shallow } from 'enzyme'
import { tenant, user, shipment, identity, match } from '../../mocks'
// eslint-disable-next-line import/first no-named-as-default
import ShipmentDetails from './ShipmentDetails'

jest.mock('../../constants', () => {
  const format = () => 19
  const add = () => ({ format })

  const moment = () => ({
    format,
    add
  })

  return { moment }
})
jest.mock('../ShipmentLocationBox/getRequests', () => ({
  incoterms: (a, b, c) => () => 'incotermResults'
}))
jest.mock('../../helpers', () => ({
  isEmpty: () => true,
  camelize: x => x
}))

const editedShipment = {
  ...shipment,
  cargo_items_attributes: [],
  containers_attributes: [],
  planned_pickup_date: 'planned_pickup_date',
  origin_user_input: 'origin_user_input',
  destination_user_input: 'destination_user_input',
  incoterm: 'incoterm',
  trucking: { on_carriage: {}, pre_carriage: {} },
  origin_id: 1,
  destination_id: 12,
  has_on_carriage: false,
  has_pre_carriage: false,
  load_type: 'cargo_item',
  direction: 'FOO_DIRECTION'
}

const editedTenant = {
  ...tenant,
  data: {
    scope: {
      carriage_options: {
        on_carriage: {
          FOO_DIRECTION: 'mandatory'
        },
        pre_carriage: {
          FOO_DIRECTION: 'optional'
        }
      }
    }
  }
}

const propsBase = {
  shipmentData: { shipment: editedShipment, cargoItemTypes: {} },
  setShipmentDetails: identity,
  messages: ['FOO_MESSAGE', 'BAR_MESSAGE'],
  setStage: identity,
  getOffers: identity,
  prevRequest: {
    shipment: editedShipment
  },
  shipmentDispatch: {
    goTo: identity,
    getDashboard: identity
  },
  bookingSummaryDispatch: {
    update: identity
  },
  tenant: editedTenant,
  user,
  match,
  bookingHasCompleted: () => false
}

let originalDate
const constantDate = new Date('2017-06-13T04:41:20')
beforeEach(() => {
  originalDate = Date
  // eslint-disable-next-line no-global-assign
  Date = class extends Date {
    constructor () {
      return constantDate
    }
  }
})

afterEach(() => {
  // eslint-disable-next-line no-global-assign
  Date = originalDate
})

test.skip('shallow rendering', () => {
  expect(shallow(<ShipmentDetails {...propsBase} />)).toMatchSnapshot()
})
