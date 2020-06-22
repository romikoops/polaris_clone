import React from 'react'
import { shallow } from 'enzyme'
import ErrorMessage from './index'
import { tenant } from '../../../../mocks'

let wrapper

const props = {
  tenant,
  error: { modeOfTransport: 'truck', max: 1000, actual: 1100 },
  type: 'warning'
}

const allMotsError = {
  modesOfTransport: ['air', 'ocean'],
  max: 1000.10,
  actual: 25919.9999999996,
  allMotsExceeded: true
}

describe('Context: Functional', () => {
  it('do not render with wront error name', () => {
    wrapper = shallow(<ErrorMessage {...props} type="error" name="invalid-error" />)
    expect(wrapper.html()).toBeNull()
  })

  it('renders the correct message for payloadInKg', () => {
    wrapper = shallow(<ErrorMessage {...props} type="error" name="payloadInKg" />)

    const text = wrapper.text()

    expect(text).toContain('The total weight of the specified cargo')
    expect(text).toContain('(1100 kg) exceeds the maximum (1000 kg)')
    expect(text).toContain('Please contact our customer service department')
    expect(text).toContain('to place an order for your cargo: support@demo.com')
  })

  it('renders the correct message for chargeableWeight', () => {
    wrapper = shallow(<ErrorMessage {...props} name="chargeableWeight" />)

    const text = wrapper.text()

    expect(text).toContain('Please note that the total chargeable weight for')
    expect(text).toContain('Truck Freight shipments (1100 Kg) exceeds the maximum (1000 Kg).')
  })

  it('change the mot to all when all mots were exceeded for chargeableWeight', () => {
    wrapper = shallow(<ErrorMessage {...props} name="chargeableWeight" error={allMotsError} />)

    const text = wrapper.text()

    expect(text).toContain('Please note that the total chargeable weight for')
    expect(text).toContain('All Freight shipments (25920 Kg) exceeds the maximum (1000 Kg).')
  })

  it('renders the correct message for volume', () => {
    wrapper = shallow(<ErrorMessage {...props} name="volume" />)

    const text = wrapper.text()

    expect(text).toContain('Please note that the total volume for Truck Freight shipments (1100 m³)')
    expect(text).toContain('exceeds the maximum (1000 m³).')
  })

  it('change the mot to all when all mots were exceeded for volume', () => {
    wrapper = shallow(<ErrorMessage {...props} name="volume" error={allMotsError} />)

    const text = wrapper.text()

    expect(text).toContain('Please note that the total volume for All Freight shipments (25920 m³)')
    expect(text).toContain('exceeds the maximum (1000 m³).')
  })
})
