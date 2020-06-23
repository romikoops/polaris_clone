import { mount as enzymeMount } from 'enzyme'
import Formsy from 'formsy-react'
import React from 'react'
import { Provider } from 'react-redux'
import createMockStore from 'redux-mock-store'
import { routeSelectionStateMock } from '../mocks'
import AddressFields from './Form/AddressFields/fields'
import RouteSectionConnected from './index'
import { address, address2 } from '../../../mock'

let wrapper
const mockStore = createMockStore()
const mockState = (origin = address, destination = address2) => {
  const state = routeSelectionStateMock()

  state.bookingProcess.shipment.origin = origin
  state.bookingProcess.shipment.destination = destination

  return state
}

beforeEach(() => {
  jest.resetModules()
})
describe('Address fields visibility', () => {
  const addressFields = () => wrapper.find(AddressFields)
  const mount = (store) => {
    wrapper = enzymeMount(<RouteSectionConnected />, { wrappingComponent: RouteSectionWrapper(store) })
  }

  it('render address fields', () => {
    mount(mockStore(mockState()))

    const fields = addressFields()

    expect(fields.at(0).prop('hide')).toBeFalsy()
    expect(fields.at(1).prop('hide')).toBeFalsy()
  })

  it('not render address fields based on scope', () => {
    const state = mockState()
    state.app.tenant.scope.address_fields = false
    mount(mockStore(state))

    const fields = addressFields()

    expect(fields.at(0).prop('hide')).toBeTruthy()
    expect(fields.at(1).prop('hide')).toBeTruthy()
  })
})

const RouteSectionWrapper = (store) => ({ children }) => (
  <Provider store={store}>
    <Formsy>
      {children}
    </Formsy>
  </Provider>
)

jest.mock('./Map', () => ({ children }) => children(jest.fn(), jest.fn(), jest.fn(), jest.fn()))
jest.mock('uuid', () => ({ v1: () => '6199642e-95d2-11ea-bb37-0242ac130002' }))

jest.mock('redux', () => {
  const actual = jest.requireActual('redux')

  return {
    ...actual,
    bindActionCreators: () => ({
      getLastAvailableDate: jest.fn(),
      refreshMaxDimensions: jest.fn(),
      updatePageData: jest.fn(),
      updateShipment: jest.fn(),
      clearError: jest.fn()
    })
  }
})
