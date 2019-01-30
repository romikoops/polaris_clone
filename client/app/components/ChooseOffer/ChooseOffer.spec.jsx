import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change,
  identity,
  shipment,
  shipmentData,
  tenant,
  theme,
  match,
  firstResult,
  user
} from '../../mocks'
import ChooseOffer from './ChooseOffer'

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
  lastAvailableDate: new Date('2017-07-13T04:41:20'),
  tenant,
  match,
  bookingHasCompleted: () => false
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
  const props = change(
    propsBase,
    'shipmentData.schedules',
    null
  )

  expect(shallow(<ChooseOffer {...props} />)).toMatchSnapshot()
})

test('selectedOffers is truthy', () => {
  const wrapper = shallow(<ChooseOffer {...propsBase} />)
  wrapper.setState({ selectedOffers: [firstResult] })
  expect(wrapper).toMatchSnapshot()
})

test('tenant.scope.hide_grand_total is false', () => {
  const props = change(
    propsBase,
    'tenant.scope.hide_grand_total',
    false
  )
  const wrapper = shallow(<ChooseOffer {...props} />)
  wrapper.setState({ selectedOffers: [firstResult] })
  expect(wrapper).toMatchSnapshot()
})

test('state.showModal is true', () => {
  const wrapper = shallow(<ChooseOffer {...propsBase} />)
  wrapper.setState({ showModal: true })
  expect(wrapper).toMatchSnapshot()
})
