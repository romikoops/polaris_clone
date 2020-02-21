import configureStore from 'redux-mock-store'
import thunk from 'redux-thunk'
import clientsActions from './clients.actions'
import { clientsConstants } from '../constants'

const { fetch } = window
const middlewares = [thunk]
const mockStore = configureStore(middlewares)

const dummyMember = {
  id: 123
}

const group = {
  id: 1
}

describe('clearMarginsList', () => {
  const store = mockStore({})
  beforeEach(() => {
    fetch.resetMocks()
  })
  afterEach(() => {
    store.clearActions()
  })

  it('clears the margins section', () => {
    expect.assertions(1)
   
    const expectedAction = { type: clientsConstants.CLEAR_MARGINS_LIST }
    expect(clientsActions.clearMarginsList()).toEqual(expectedAction)
  })
})

describe('removeMembership', () => {
  const store = mockStore({})
  beforeEach(() => {
    fetch.resetMocks()
  })
  afterEach(() => {
    store.clearActions()
  })

  it('removes a specific member', () => {
    const callError = new TypeError("Cannot read property 'id' of undefined")
    fetch.once(() => new Promise((resolve) => setTimeout(() => resolve({ body: JSON.stringify({ group }) }), 10)))
    const expectedActions = [
      { type: clientsConstants.REMOVE_MEMBERSHIP_REQUEST },
      { type: clientsConstants.REMOVE_MEMBERSHIP_SUCCESS, payload: dummyMember.id },
      { type: clientsConstants.REMOVE_MEMBERSHIP_ERROR, error: callError }
    ]

    return store.dispatch(clientsActions.removeMembership(dummyMember.id)).then(() => {
      expect(store.getActions()).toEqual(expectedActions)
    })
  })
})