import configureStore from 'redux-mock-store'
import thunk from 'redux-thunk'
import appActions from './app.actions'
import { appConstants } from '../constants/app.constants'

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

  it('creates SET_TENANT_ID_FAILURE when fetching the id is null', () => {
    expect.assertions(1)
    fetch.once(() => new Promise(resolve => setTimeout(() => resolve({ body: JSON.stringify({ data: { tenant_id: null } }) }), 10)))
    const expectedActions = [
      { type: appConstants.SET_TENANT_ID_REQUEST },
      { type: appConstants.SET_TENANT_ID_ERROR, error: { text: 'Null Id'} }
    ]

    
    return store.dispatch(appActions.getTenantId()).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })

  it('creates SET_TENANT_ID_ERROR when fetching the id is not successful', () => {
    expect.assertions(1)
    fetch.mockRejectOnce(() => new Promise((resolve, reject) => setTimeout(() => reject({ body: JSON.stringify({ }) }), 10)))
    const expectedActions = [
      { type: appConstants.SET_TENANT_ID_REQUEST },
      { type: appConstants.SET_TENANT_ID_ERROR, error: { text: 'Invalid Response'} }
    ]


    return store.dispatch(appActions.getTenantId()).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })

  it('creates SET_TENANT_ID_SUCCESS when fetching the id is successful', () => {
    expect.assertions(1)
    fetch.once(() => new Promise(resolve => setTimeout(() => resolve({ body: JSON.stringify({ data: { tenant_id: 1 } }) }), 10)))
          .once(() => new Promise(resolve => setTimeout(() => resolve({ body: JSON.stringify({ data: { tenant: {} } }) }), 10)))
    const expectedActions = [
      { type: appConstants.SET_TENANT_ID_REQUEST },
      { type: appConstants.SET_TENANT_ID_SUCCESS, payload: 1 }
    ]
    
    return store.dispatch(appActions.getTenantId()).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })
})
