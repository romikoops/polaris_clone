import createHistory from 'history/createBrowserHistory'
import { applyMiddleware, createStore, compose } from 'redux'
import { routerMiddleware } from 'react-router-redux'
import thunkMiddleware from 'redux-thunk'
import throttle from 'lodash/throttle'
import { createLogger } from 'redux-logger'
import * as Sentry from '@sentry/browser'
import createSentryMiddleware from '../helpers/sentry-middleware'

import { saveState, loadState } from '../helpers'
import rootReducer from '../reducers'
import DevTools from '../containers/DevTools'

const isDevelopment = process.env.NODE_ENV === 'development'

export const history = createHistory()
export function configureStore () {
  const store = isDevelopment ? createStore(
    rootReducer,
    loadState(),
    compose(
      applyMiddleware(...[
        routerMiddleware(history),
        thunkMiddleware,
        createLogger()
      ].filter(Boolean)),
      DevTools.instrument()
    )
  )
    : createStore(
      rootReducer,
      loadState(),
      compose(applyMiddleware(...[
        createSentryMiddleware(Sentry),
        thunkMiddleware,
        routerMiddleware(history)
      ].filter(Boolean)))
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
