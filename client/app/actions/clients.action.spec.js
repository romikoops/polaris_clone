import configureStore from 'redux-mock-store'
import thunk from 'redux-thunk'
import clientsActions from './clients.actions'
import { clientsConstants } from '../constants'

const middlewares = [thunk]
const mockStore = configureStore(middlewares)

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