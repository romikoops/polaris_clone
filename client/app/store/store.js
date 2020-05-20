import createHistory from 'history/createBrowserHistory'
import { applyMiddleware, createStore, compose } from 'redux'
import { routerMiddleware } from 'react-router-redux'
import thunkMiddleware from 'redux-thunk'
import throttle from 'lodash/throttle'
import * as Sentry from '@sentry/browser'
import beaconMiddleWare from '../helpers/beacon'
import createSentryMiddleware from '../helpers/sentry-middleware'

import { saveState, loadState } from '../helpers'
import rootReducer from '../reducers'
import createActivityMiddleware from '../helpers/activity-middleware'

export const history = createHistory()

/* eslint-disable no-underscore-dangle */
const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
/* eslint-enable */

let middleware = [
  createSentryMiddleware(Sentry),
  createActivityMiddleware(),
  thunkMiddleware,
  routerMiddleware(history),
  beaconMiddleWare
]

export const store = createStore(
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
      bookingProcess: oldState.bookingProcess,
      tenant: oldState.tenant,
      admin: oldState.admin,
      bookingSummary: oldState.bookingSummary,
      clients: oldState.clients
    })
  }),
  1000
)
