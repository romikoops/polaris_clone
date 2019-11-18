import configureStore from 'redux-mock-store'
import thunk from 'redux-thunk'
import { v4 } from 'uuid'
import adminActions from './admin.actions'
import { adminConstants, alertConstants } from '../constants'


const middlewares = [thunk]
const mockStore = configureStore(middlewares)

describe('deletePricing', () => {
  const dummyPricing = {
    id: 123,
    group_id: v4(),
    tenant_id: 1,
    itinerary_id: 2
  }
  const store = mockStore({})
  beforeEach(() => {
    fetch.resetMocks()
  })
  afterEach(() => {
    store.clearActions()
  })

  it('creates DELETE_PRICING_SUCCESS when it originates from a group', () => {
    expect.assertions(1)
    fetch.once(() => new Promise(resolve => setTimeout(() => resolve({ body: JSON.stringify({ data: { tenant_id: null } }) }), 10)))
    const expectedActions = [
      { type: adminConstants.DELETE_PRICING_REQUEST },
      { type: adminConstants.DELETE_PRICING_SUCCESS, payload: { fromGroup: true, pricing: dummyPricing } }
    ]

    return store.dispatch(adminActions.deletePricing(dummyPricing, true)).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })

  it('creates DELETE_PRICING_SUCCESS when it originates from a group', () => {
    expect.assertions(1)
    fetch.once(() => new Promise(resolve => setTimeout(() => resolve({ body: JSON.stringify({ data: { tenant_id: null } }) }), 10)))
    const expectedActions = [
      { type: adminConstants.DELETE_PRICING_REQUEST },
      { type: adminConstants.DELETE_PRICING_SUCCESS, payload: { fromGroup: true, pricing: dummyPricing } }
    ]

    return store.dispatch(adminActions.deletePricing(dummyPricing, true)).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })

  it('creates DELETE_PRICING_ERROR when fetching the id is not successful', () => {
    expect.assertions(1)
    const callError = new Error('fake error message')
    fetch.once(() => new Promise((resolve, reject) => setTimeout(() => reject(callError), 10)))
    const expectedActions = [
      { type: adminConstants.DELETE_PRICING_REQUEST },
      { type: adminConstants.DELETE_PRICING_FAILURE, error: callError },
      { type: alertConstants.ERROR, message: callError }
    ]
    return store.dispatch(adminActions.deletePricing(dummyPricing, false)).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })
})
