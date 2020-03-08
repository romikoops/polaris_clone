import { createMiddleware } from 'redux-beacon'
import logger from '@redux-beacon/logger'
import OfflineWeb from '@redux-beacon/offline-web'
import { loadPreferences, onPreferencesSaved } from '@segment/consent-manager'
import { has, get } from 'lodash'
import Segment from './beacon/segment'
import eventsMap from './beacon/events'

// Track consent state
let consent = has(loadPreferences(), 'customPreferences.functional')
onPreferencesSaved((preferences) => {
  consent = has(preferences, 'customPreferences.functional')
})

// Enable buffering of events before consent
const offlineStorage = OfflineWeb((state) => consent)

const eventsHandler = (action) => (_action, _prevState, _nextState) => {
  if (!eventsMap[action.type]) { return null }
  if (get(_nextState, 'app.tenant.scope.exclude_analytics', false) === true) { return null }

  return eventsMap[action.type](_action, _nextState)
}

const beaconMiddleWare = createMiddleware(eventsHandler, Segment, { logger, offlineStorage })

export default beaconMiddleWare
