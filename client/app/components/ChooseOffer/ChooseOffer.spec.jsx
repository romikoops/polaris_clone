import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, user, shipmentData, tenant, shipment } from '../../mocks'
import { ChooseOffer } from './ChooseOffer'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  theme,
  user,
  shipmentData,
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
  tenant
}

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
  const props = {
    ...propsBase,
    shipmentData: {
      ...shipmentData,
      schedules: null
    }
  }
  expect(shallow(<ChooseOffer {...props} />)).toMatchSnapshot()
})
