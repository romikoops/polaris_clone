import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, user, shipmentData, tenant, shipment } from '../../mocks'
import { ChooseOffer } from './ChooseOffer'

shipmentData.shipment = {
  ...shipmentData.shipment,
  load_type: 'FOO_LOAD_TYPE'
}
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

test.only('shallow render', () => {
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
