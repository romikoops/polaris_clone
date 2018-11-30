import { createMiddleware } from 'redux-beacon'
import logger from '@redux-beacon/logger'

const GoogleTagManager = (events) => {
  window.dataLayer = window.dataLayer || []

  events.forEach((event) => {
    window.dataLayer.push(event)
  })
}

// Match the event definition to a Redux action:
const eventsMap = {
  SET_TENANT_SUCCESS: (action, prevState, nextState) => ({
    event: action.type,
    tenant: nextState.app.tenant.subdomain
  })
}

const beaconMiddleWare = createMiddleware(eventsMap, GoogleTagManager, { logger })

export default beaconMiddleWare
