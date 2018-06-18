import * as React from 'react'
import { shallow } from 'enzyme'
import { tenant, user, shipment, identity } from '../../mocks'

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
jest.mock('../Checkbox/Checkbox', () => ({
  // eslint-disable-next-line react/prop-types
  Checkbox: ({ children }) => <div>{children}</div>
}))
jest.mock('./getModals', () => ({
  // eslint-disable-next-line react/prop-types
  default: ({ children }) => <div>{children}</div>
}))
jest.mock('../Incoterm/Box', () => ({
  // eslint-disable-next-line react/prop-types
  IncotermBox: ({ children }) => <div>{children}</div>
}))
jest.mock('../Incoterm/Row', () => ({
  // eslint-disable-next-line react/prop-types
  IncotermRow: ({ children }) => <div>{children}</div>
}))
jest.mock('../Tooltip/Tooltip', () => ({
  // eslint-disable-next-line react/prop-types
  Tooltip: ({ children }) => <div>{children}</div>
}))
jest.mock('../FlashMessages/FlashMessages', () => ({
  // eslint-disable-next-line react/prop-types
  FlashMessages: ({ children }) => <div>{children}</div>
}))
jest.mock('react-day-picker/DayPickerInput', () => ({
  // eslint-disable-next-line react/prop-types
  default: ({ children }) => <div>{children}</div>
}))
jest.mock('../../hocs/GmapsLoader', () => ({
  // eslint-disable-next-line react/prop-types
  default: ({ children }) => <div>{children}</div>
}))
jest.mock('../TruckingDetails/TruckingDetails', () => ({
  // eslint-disable-next-line react/prop-types
  default: ({ children }) => <div>{children}</div>
}))
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ children }) => <div>{children}</div>
}))
jest.mock('../ShipmentLocationBox/ShipmentLocationBox', () => ({
  // eslint-disable-next-line react/prop-types
  ShipmentLocationBox: ({ children }) => <div>{children}</div>
}))
jest.mock('../ShipmentContainers/ShipmentContainers', () => ({
  // eslint-disable-next-line react/prop-types
  ShipmentContainers: ({ children }) => <div>{children}</div>
}))
jest.mock('../ShipmentCargoItems/ShipmentCargoItems', () => ({
  // eslint-disable-next-line react/prop-types
  ShipmentCargoItems: ({ children }) => <div>{children}</div>
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <div>{children}</div>
}))

// eslint-disable-next-line import/first
import { ShipmentDetails } from './ShipmentDetails'

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
  user
}

let originalDate
const constantDate = new Date('2017-06-13T04:41:20')
beforeEach(() => {
  // eslint-disable-next-line no-global-assign
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

test('shallow rendering', () => {
  expect(shallow(<ShipmentDetails {...propsBase} />)).toMatchSnapshot()
})
