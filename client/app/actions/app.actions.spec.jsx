import configureStore from 'redux-mock-store'
import thunk from 'redux-thunk'
import { appActions } from './app.actions'
import { appConstants } from '../constants/app.constants'
import { authenticationConstants } from '../constants/authentication.constants'
import { user } from '../mocks/'

const middlewares = [thunk]
const mockStore = configureStore(middlewares)

const { localStorage, fetch } = global

describe('async actions', () => {
  const store = mockStore({})
  beforeEach(() => {
    fetch.resetMocks()
  })
  afterEach(() => {
    store.clearActions()
  })

  it('creates SET_ORGANIZATION_ID_FAILURE when fetching the id is null', () => {
    expect.assertions(1)
    fetch.mockResponses(
      [
        JSON.stringify({ data: { organization_id: null } }),
        { status: 200 }
      ]
    )

    const expectedActions = [
      { type: appConstants.SET_ORGANIZATION_ID_REQUEST },
      { type: appConstants.SET_ORGANIZATION_ID_ERROR, error: { text: 'Null Id' } }
    ]

    return store.dispatch(appActions.getTenantId()).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })

  it('creates SET_ORGANIZATION_ID_ERROR when fetching the id is not successful', () => {
    expect.assertions(1)
    fetch.mockRejectOnce(() => new Promise((resolve, reject) => setTimeout(() => reject({ body: JSON.stringify({ }) }), 10)))
    const expectedActions = [
      { type: appConstants.SET_ORGANIZATION_ID_REQUEST },
      { type: appConstants.SET_ORGANIZATION_ID_ERROR, error: { text: 'Invalid Response' } }
    ]

    return store.dispatch(appActions.getTenantId()).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })

  it('creates SET_ORGANIZATION_ID_SUCCESS when fetching the id is successful', () => {
    expect.assertions(1)
    fetch.mockResponses(
      [
        JSON.stringify({ data: { organization_id: 1 } }),
        { status: 200 }
      ],
      [
        JSON.stringify({ data: { tenant: {} } }),
        { status: 200 }
      ]
    )
    const expectedActions = [
      { type: appConstants.SET_ORGANIZATION_ID_REQUEST },
      { type: appConstants.SET_ORGANIZATION_ID_SUCCESS, payload: 1 }
    ]

    return store.dispatch(appActions.getTenantId()).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })

  it("fetches the user after setting the user's currency", () => {
    expect.assertions(1)
    fetch.mockResponses(
      [
        JSON.stringify({ data: { user, rates: [] } }),
        { status: 200 }
      ]
    )
    const expectedActions = [
      { type: appConstants.SET_CURRENCY_REQUEST, payload: 'EUR' },
      { type: appConstants.SET_CURRENCY_SUCCESS, payload: [] },
      { type: authenticationConstants.SET_USER, user }
    ]

    return store.dispatch(appActions.setCurrency('EUR')).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })
})
