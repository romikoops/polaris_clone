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

const edittedShipment = {
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
  load_type: 'cargo_item'
}

const propsBase = {
  shipmentData: { shipment: edittedShipment },
  setShipmentDetails: identity,
  messages: ['FOO_MESSAGE', 'BAR_MESSAGE'],
  setStage: identity,
  prevRequest: {
    shipment: edittedShipment
  },
  shipmentDispatch: {
    goTo: identity,
    getDashboard: identity
  },
  bookingSummaryDispatch: {
    update: identity
  },
  tenant,
  user
}

const createShallow = propsInput => shallow(<ShipmentDetails {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})
