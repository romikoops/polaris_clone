import * as React from 'react'
import { shallow } from 'enzyme'
import {
  route,
  user,
  addresses,
  shipment,
  identity,
  theme
} from '../../mocks/index'
// eslint-disable-next-line import/first no-named-as-default
import ShipmentSummaryBox from './ShipmentSummaryBox'

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
  startHub: { address: { geocoded_address: 'FOO_ADDRESS' }, data: { name: 'FOO' } },
  endHub: { address: { geocoded_address: 'BAR_ADDRESS' }, data: { name: 'BAR' } }
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
  addresses
}

let originalDate
const constantDate = new Date('2017-06-13T04:41:20')
beforeEach(() => {
  originalDate = Date
  Date = class extends Date {
    constructor () {
      return constantDate
    }
  }
})

afterEach(() => {
  Date = originalDate
})

/**
 * Wait for static function switch icon to be moved out of the component
 */
test.skip('shallow rendering', () => {
  expect(shallow(<ShipmentSummaryBox {...propsBase} />)).toMatchSnapshot()
})
