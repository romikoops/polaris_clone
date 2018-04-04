import * as React from 'react'
import { shallow } from 'enzyme'
import { route, user, locations, shipment, identity, theme } from '../../mocks'

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
  capitalize: x => x,
  gradientCSSGenerator: x => x,
  gradientGenerator: x => x,
  gradientTextGenerator: x => x
}))
jest.mock('../Tooltip/Tooltip', () => ({
  // eslint-disable-next-line react/prop-types
  Tooltip: ({ children }) => <div>{children}</div>
}))
jest.mock('../Price/Price', () => ({
  // eslint-disable-next-line react/prop-types
  Price: ({ children }) => <div>{children}</div>
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line import/first
import { ShipmentSummaryBox } from './ShipmentSummaryBox'

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

const hubs = {
  startHub: { location: { geocoded_address: 'FOO_ADDRESS' }, data: { name: 'FOO' } },
  endHub: { location: { geocoded_address: 'BAR_ADDRESS' }, data: { name: 'BAR' } }
}

const propsBase = {
  name: '',
  onChange: identity,
  pickupDate: 1,
  theme,
  shipment: edittedShipment,
  hubs,
  route,
  user,
  total: 9,
  locations
}

let originalDate

beforeEach(() => {
  // eslint-disable-next-line no-global-assign
  originalDate = Date
  // eslint-disable-next-line no-global-assign
  Date = () => 1462361249717
})

afterEach(() => {
  // eslint-disable-next-line no-global-assign
  Date = originalDate
})

// eslint-disable-next-line
test.skip('shallow rendering', () => {
  expect(shallow(<ShipmentSummaryBox {...propsBase} />)).toMatchSnapshot()
})
