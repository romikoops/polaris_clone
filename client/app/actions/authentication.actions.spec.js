import configureStore from 'redux-mock-store'
import thunk from 'redux-thunk'
import authenticationActions from './authentication.actions'
import { authenticationConstants } from '../constants/authentication.constants'
import { userConstants } from '../constants/user.constants'
import { user } from '../mocks'

const { fetch, localStorage } = global 

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

  it('creates SAML_USER_SUCCESS when fetching the id is successful', () => {
    expect.assertions(1)
    fetch.mockResponses(
      [
        JSON.stringify({ data: user }),
        { status: 200 }
      ],
      [
        JSON.stringify({ data: {} }),
        { status: 200 }
      ]
    )
    const expectedActions = [
      { type: authenticationConstants.SAML_USER_REQUEST, payload: undefined },
      { type: authenticationConstants.SAML_USER_SUCCESS, payload: user },
      { type: userConstants.GET_DASHBOARD_REQUEST, payload: undefined }
    ]
    const payload = { userId: 1, headers: {}, organizationId: 1 }

    return store.dispatch(authenticationActions.postSamlActions(payload)).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })
  it('creates LOGIN_SUCCESS when login is successful', () => {
    expect.assertions(2)
    const authHeader = {
      access_token: '1234',
      token_type: 'Bearer'
    }
    fetch.mockResponses(
      [
        JSON.stringify(authHeader),
        { status: 200 }
      ],
      [
        JSON.stringify({ data: user }),
        { status: 200 }
      ],
      [
        JSON.stringify({ data: {} }),
        { status: 200 }
      ]
    )

    const payload = { email: 'test@email.com', password: '123456789' }
    const expectedActions = [
      { type: authenticationConstants.LOGIN_REQUEST, user: { email: payload.email } },
      { type: authenticationConstants.LOGIN_SUCCESS, user },
      { type: authenticationConstants.SET_USER, user },
      { type: '@@router/CALL_HISTORY_METHOD', payload: { args: ['/account'], method: 'push' } }
    ]

    return store.dispatch(authenticationActions.login(payload)).then(() => {
      expect(store.getActions()).toEqual(expect.arrayContaining(expectedActions))
      expect(JSON.parse(localStorage.getItem('authHeader'))).toEqual(authHeader)
    })
  })
  it('creates LOGIN_FAILURE when login is unsuccessful', () => {
    expect.assertions(1)
    const errorResponse = { code: 1051, message: 'Invalid email or password.', success: false }
    fetch.mockResponses(
      [
        JSON.stringify(errorResponse),
        { status: 401 }
      ]
    )
    const payload = { email: 'test@email.com', password: '123456789' }
    const expectedActions = [
      { type: authenticationConstants.LOGIN_REQUEST, user: { email: payload.email } },
      { type: authenticationConstants.LOGIN_FAILURE, loginFailure: { error: errorResponse, persistState: false } }
    ]

    return store.dispatch(authenticationActions.login(payload)).then(() => {
      expect(store.getActions()).toEqual(expect.arrayContaining(expectedActions))
    })
  })
})
