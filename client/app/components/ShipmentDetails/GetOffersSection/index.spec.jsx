import * as React from 'react'
import { shallow, mount } from 'enzyme'
import GetOffersSection from '.'

import {
  selectedDay,
  tenant,
  user,
  theme,
  cargoItem
} from '../mocks'

const shipmentBase = {
  selectedDay,
  incoterm: {},
  cargoUnits: [cargoItem],
  preCarriage: false,
  onCarriage: false,
  direction: 'export',
  loadType: 'cargo_item'
}

const propsBase = {
  user,
  tenant,
  shipment: shipmentBase,
  theme,
  totalShipmentErrors: {
    payloadInKg: {}
  }
}

describe('<GetOffersSection />', () => {
  it('renders with empty props', () => {
    expect(() => shallow(<GetOffersSection />)).toThrow()
  })

  it('renders correctly', () => {
    const shipment = { ...shipmentBase, loadType: 'container' }
    expect(shallow(<GetOffersSection {...propsBase} shipment={shipment} />)).toMatchSnapshot()
  })

  it('renders the Error Messages', () => {
    const totalShipmentErrors = {
      payloadInKg: {
        errors: [{ modeOfTransport: 'general', max: 40000, actual: 10000000 }],
        type: 'error'
      }
    }

    const wrapper = mount(<GetOffersSection {...propsBase} totalShipmentErrors={totalShipmentErrors} />)
    expect(wrapper.text()).toContain('The total weight of the specified cargo')
  })

  it('ignores empty Error Messages', () => {
    const totalShipmentErrors = {
      payloadInKg: {}
    }

    const wrapper = mount(<GetOffersSection {...propsBase} totalShipmentErrors={totalShipmentErrors} />)
    expect(wrapper.text()).not.toContain('The total weight of the specified cargo')
  })
})

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => (Component) => Component
}))
