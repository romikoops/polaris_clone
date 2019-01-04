import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, user, shipmentData, tenant, shipment, change, match } from '../../mocks'
import { unconnectedChooseOffer as ChooseOffer} from './ChooseOffer'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const editedShipmentData = change(
  shipmentData,
  'shipment.trucking',
  {
    pre_carriage: {}
  }
)

const propsBase = {
  theme,
  user,
  shipmentData: editedShipmentData,
  chooseOffer: identity,
  messages: ['FOO_MESSAGE', 'BAR_MESSAGE'],
  req: {},
  setStage: identity,
  prevRequest: {
    shipment
  },
  shipmentDispatch: {
    goTo: identity
  },
  lastAvailableDate: new Date('2017-07-13T04:41:20'),
  tenant,
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

test('shallow render', () => {
  expect(shallow(<ChooseOffer {...propsBase} />)).toMatchSnapshot()
})

test('shipmentData is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: null
  }
  expect(shallow(<ChooseOffer {...props} />)).toMatchSnapshot()
})

test('shipmentData.schedules is falsy', () => {
  const props = change(
    propsBase,
    'shipmentData.schedules',
    null
  )

  expect(shallow(<ChooseOffer {...props} />)).toMatchSnapshot()
})
