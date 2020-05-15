import { mount as enzymeMount } from 'enzyme'
import Formsy from 'formsy-react'
import React from 'react'
import { Provider } from 'react-redux'
import createMockStore from 'redux-mock-store'
import { routeSelectionStateMock } from '../mocks'
import AddressFields from './Form/AddressFields/fields'
import RouteSectionConnected from './index'

let wrapper
const mockStore = createMockStore()
describe('Address fields visibility', () => {
  const addressFields = () => wrapper.find(AddressFields)
  const mount = (store) => {
    wrapper = enzymeMount(<RouteSectionConnected />, { wrappingComponent: RouteSectionWrapper(store) })
  }

  it('render address fields', () => {
    mount(mockStore(routeSelectionStateMock()))

    const fields = addressFields()

    expect(fields.at(0).prop('hide')).toBeFalsy()
    expect(fields.at(1).prop('hide')).toBeFalsy()
  })

  it('not render address fields', () => {
    const state = routeSelectionStateMock()
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
