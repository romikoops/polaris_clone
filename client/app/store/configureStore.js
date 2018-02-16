import createHistory from 'history/createBrowserHistory'
import { applyMiddleware, createStore, compose } from 'redux'
import { routerMiddleware } from 'react-router-redux'
import thunkMiddleware from 'redux-thunk'
import throttle from 'lodash/throttle'
import { createLogger } from 'redux-logger'

import { saveState, loadState } from '../helpers'
import rootReducer from '../reducers'
import DevTools from '../containers/DevTools'

const isDevelopment = process.env.NODE_ENV === 'development'

export const history = createHistory()
export function configureStore () {
  const store = createStore(rootReducer, loadState(), compose(applyMiddleware(...[
    routerMiddleware(history), isDevelopment ? createLogger() : null, thunkMiddleware
  ].filter(Boolean)), isDevelopment ? DevTools.instrument() : null))
  store.subscribe(throttle(() => {
    const oldState = store.getState()
    const bData = oldState.bookingData
    saveState({
      bookingData: bData,
      tenant: oldState.tenant,
      admin: oldState.admin
    })
  }), 1000)
  return store
}
