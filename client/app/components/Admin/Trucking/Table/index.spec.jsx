import React from 'react'
import { mount } from 'enzyme'
import TruckingTable from './index'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => (Component) => Component
}))

const viewTruckingMock = jest.fn()
const setTargetTruckingMock = jest.fn()

const defaultProps = {
  clientsDispatch: {
    getGroupsForList: () => {}
  },
  adminDispatch: {
    viewTrucking: viewTruckingMock
  },
  hub: {
    id: 1
  },
  truckingPricings: [
    {
      courier: 'Maersk',
      truckingPricing: {
        truck_type: 'default',
        group_id: '',
        cargo_class: 'lcl',
        carriage: '',
        destination: 'Shanghai Port'
      }
    }
  ],
  groups: [
    {
      name: 'Example group'
    }
  ],
  scope: {},
  setTargetTruckingId: setTargetTruckingMock,
  truckingProviders: ['Maersk', 'Greencarrier']
}
describe('TruckingTable', () => {
  let wrapper

  describe('context: deep rendering', () => {
    beforeEach(() => {
      wrapper = mount(<TruckingTable {...defaultProps} />)
    })

    it('should render the filters tor the providers filter', () => {
      const node = wrapper.find('#provider-select')
      node.simulate('change', { target: { value: 'Greencarrier' } })
      expect(viewTruckingMock).toHaveBeenCalled()
    })

    it('calls the view pricing on click of trucking cell item', () => {
      const node = wrapper.find('div#courier-item')
      node.simulate('click')
      expect(setTargetTruckingMock).toHaveBeenCalled()
    })
  })
})
