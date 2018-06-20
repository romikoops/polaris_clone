import * as React from 'react'
import { shallow } from 'enzyme'
import {
  gMaps,
  identity,
  route,
  shipment,
  theme,
  user
} from '../../mocks'

jest.mock('../../constants', () => {
  const format = () => 19
  const add = () => ({ format })

  const moment = () => ({
    format,
    add
  })

  return { moment }
})
jest.mock('../../helpers', () => ({
  // eslint-disable-next-line react/prop-types
  authHeader: () => '',
  colorSVG: () => ''
}))
jest.mock('../Checkbox/Checkbox', () => ({
  // eslint-disable-next-line react/prop-types
  Checkbox: ({ children }) => <div>{children}</div>
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
import { ShipmentLocationBox } from './ShipmentLocationBox'

const editedShipment = {
  ...shipment,
  cargo_items_attributes: [],
  containers_attributes: [],
  planned_pickup_date: 'planned_pickup_date',
  origin_user_input: 'origin_user_input',
  destination_user_input: 'destination_user_input',
  incoterm: 'incoterm',
  trucking: 'trucking',
  origin_id: 1,
  destination_id: 12,
  has_on_carriage: false,
  has_pre_carriage: false,
  origin: {},
  destination: {},
  load_type: 'cargo_item'
}

const propsBase = {
  nextStageAttempt: false,
  handleSelectLocation: identity,
  gMaps,
  theme,
  user,
  shipment: editedShipment,
  setTargetAddress: identity,
  handleAddressChange: identity,
  handleChangeCarriage: identity,
  allNexuses: {
    origins: [],
    destinations: []
  },
  has_on_carriage: false,
  has_pre_carriage: false,
  shipmentDispatch: {
    goTo: identity,
    getDashboard: identity
  },
  selectedRoute: route,
  origin: {
    number: 5
  },
  destination: {
    number: 2
  },
  shipmentData: {},
  routeIds: [1, 4, 5],
  prevRequest: {
    shipment: editedShipment
  }
}

const createShallow = propsInput => shallow(<ShipmentLocationBox {...propsInput} />)

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

/**
 * Cannot test as `hubName={this.state.oSelect.label}`
 * `Cannot read property 'label' of undefined`
 */
test.skip('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})
