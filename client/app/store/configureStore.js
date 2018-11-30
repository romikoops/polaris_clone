import createHistory from 'history/createBrowserHistory'
import { applyMiddleware, createStore, compose } from 'redux'
import { routerMiddleware } from 'react-router-redux'
import thunkMiddleware from 'redux-thunk'
import throttle from 'lodash/throttle'
import { createLogger } from 'redux-logger'
import * as Sentry from '@sentry/browser'
import beaconMiddleWare from '../helpers/beacon'
import createSentryMiddleware from '../helpers/sentry-middleware'

import { saveState, loadState } from '../helpers'
import rootReducer from '../reducers'

/* eslint-disable no-underscore-dangle */
const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
/* eslint-enable */

export const history = createHistory()
let middleware = [
  createSentryMiddleware(Sentry),
  thunkMiddleware,
  routerMiddleware(history),
  beaconMiddleWare
]

if (process.env.NODE_ENV !== 'production') {
  middleware = [...middleware, createLogger({ diff: true })]
}

export function configureStore () {
  const store =
  createStore(
    rootReducer,
    loadState(),
    composeEnhancers(
      applyMiddleware(...middleware)
    )
  )

  store.subscribe(
    throttle(() => {
      const oldState = store.getState()
      const bData = oldState.bookingData
      saveState({
        bookingData: bData,
        tenant: oldState.tenant,
        admin: oldState.admin,
        bookingSummary: oldState.bookingSummary
      })
    }),
    1000
  )

  return store
}
