import configureStore from 'redux-mock-store'
import thunk from 'redux-thunk'
import shipmentActions from './shipment.actions'
import { shipmentConstants } from '../constants/shipment.constants'
import { errorConstants } from '../constants/error.constants'

const { fetch } = global

const middlewares = [thunk]
const mockStore = configureStore(middlewares)

describe('async actions', () => {
  const store = mockStore({})
  beforeEach(() => {
    fetch.resetMocks()
  })
  afterEach(() => {
    store.clearActions()
  })

  it('creates GET_OFFERS_FAILURE when an error is returned', () => {
    expect.assertions(1)
    fetch.mockResponses(
      [
        JSON.stringify({ success: false, message: 'Not Logged in' }),
        { status: 200 }
      ]
    )
    const expectedActions = [
      { type: shipmentConstants.GET_OFFERS_REQUEST, shipmentData: { shipment: { id: 1 } } },
      { type: shipmentConstants.GET_OFFERS_FAILURE, error: { text: 'Not Logged in', type: 'error' } },
      { type: errorConstants.SET_ERROR, payload: { componentName: 'RouteSection', side: 'center', success: false, message: 'Not Logged in' } }
    ]

    return store.dispatch(shipmentActions.getOffers({ shipment: { id: 1 } }, false)).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })

  it('creates GET_OFFERS_SUCCESS when fetching the offers is successful', () => {
    expect.assertions(1)
    fetch.once(() => new Promise((resolve) => setTimeout(() => resolve(
      { body: JSON.stringify({ success: true, data: JSON.stringify({ shipment: { id: 1 } }) }) }
    ),
    10)))
    const expectedActions = [
      { type: shipmentConstants.GET_OFFERS_REQUEST, shipmentData: { shipment: { id: 1 } } },
      { type: shipmentConstants.GET_OFFERS_SUCCESS, shipmentData: { shipment: { id: 1 } } }
    ]

    return store.dispatch(shipmentActions.getOffers({ shipment: { id: 1 } }, false)).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })
})
