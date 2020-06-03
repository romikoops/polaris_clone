import React from 'react'
import { shallow } from 'enzyme'
import ErrorMessage from './index'
import { tenant } from '../../../../mocks'

let wrapper

const props = {
  tenant,
  error: { modeOfTransport: 'truck', max: 1000, actual: 1100 },
  type: 'warning',
  name: 'chargeableWeight'
}

describe('Context: Functional', () => {
  it('renders the correct message for chargeableWeight', () => {
    wrapper = shallow(<ErrorMessage {...props} />)

    const text = wrapper.text()

    expect(text).toContain('Please note that the total chargeable weight for')
    expect(text).toContain('Truck Freight shipments (1100 Kg) exceeds the maximum (1000 Kg).')
  })

  it('change the mot to all when all mots were exceeded ', () => {
    const error = { modesOfTransport: ['air', 'ocean'], max: 1000.10, actual: 25919.9999999996, allMotsExceeded: true }

    wrapper = shallow(<ErrorMessage {...props} error={error} />)

    const text = wrapper.text()

    expect(text).toContain('Please note that the total chargeable weight for')
    expect(text).toContain('All Freight shipments (25920 Kg) exceeds the maximum (1000 Kg).')
  })
})
