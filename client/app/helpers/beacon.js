import { createMiddleware } from 'redux-beacon'
import { loadPreferences, onPreferencesSaved } from '@itsmycargo/consent-manager'
import { has, get } from 'lodash'
import eventsMap from './beacon/events'
import Segment from './beacon/segment'
import { store } from '../store/store'

// Track consent state
let consent = has(loadPreferences(), 'customPreferences.functional')
onPreferencesSaved((preferences) => {
  consent = has(preferences, 'customPreferences.functional')
  if (consent) {
    store.dispatch({ type: 'CONSENT_RECEIVED' })
  }
})

const eventsHandler = (action) => (_action, _prevState, _nextState) => {
  if (!consent) { return null }
  if (!eventsMap[action.type]) { return null }

  if (get(_nextState, 'app.tenant.scope.exclude_analytics', false) === true) {
    return null
  }
  if (get(_nextState, 'authentication.user.email', '').indexOf("itsmycargo") != -1) {
    return null
  }

  return eventsMap[action.type](_action, _nextState)
}

const beaconMiddleWare = createMiddleware(eventsHandler, Segment)

export default beaconMiddleWare
