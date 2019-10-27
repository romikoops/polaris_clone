import { LOCATION_CHANGE } from 'react-router-redux'
import { createMiddleware } from 'redux-beacon'
import logger from '@redux-beacon/logger'
import { every, includes, keys, isEmpty } from 'lodash'
import { authenticationService } from '../services'

class GoogleTagManager {
  initialized = false

  dataLayer = []

  eventQueue = []

  generalEventsKeys = []

  generalEventsStatus = {
    IMC_GENERAL_SET_TENANT: false,
    IMC_GENERAL_CONSENT: false
  }

  loginEvents = {}

  constructor (loginEvents) {
    window.dataLayer = window.dataLayer || []

    this.dataLayer = window.dataLayer
    this.loginEvents = loginEvents
    this.handleEvents = this.handleEvents.bind(this)
    this.handleEvent = this.handleEvent.bind(this)
    this.dispatchUserEvent = this.dispatchUserEvent.bind(this)

    this.generalEventsKeys = keys(this.generalEventsStatus)
  }

  handleEvent (event) {
    const generalEvent = includes(this.generalEventsKeys, event.event)

    if (!this.initialized && !generalEvent) {
      this.eventQueue.push(event)

      return
    }

    this.dataLayer.push(event)

    if (this.initialized) {
      return
    }

    this.generalEventsStatus[event.event] = true
    this.initialized = every(this.generalEventsStatus)

    if (!this.initialized) {
      return
    }

    this.dispatchUserEvent()
    this.eventQueue.forEach(e => window.dataLayer.push(e))
    this.eventQueue = []
  }

  handleEvents (events) {
    events.forEach(this.handleEvent)
  }

  dispatchUserEvent () {
    const user = authenticationService.getStoredUser()

    if (isEmpty(user)) {
      return
    }

    const event = this.loginEvents.LOGIN_SUCCESS({ user })

    this.dataLayer.push(event)
  }
}

const generalEvents = {
  SET_TENANT_SUCCESS: (_action, _prevState, nextState) => ({
    event: 'IMC_GENERAL_SET_TENANT',
    event_type: 'internal',
    tenant: nextState.app.tenant.id,
    tenant_name: nextState.app.tenant.name
  }),

  TRACKING_CONSENT: (action, _prevState, _nextState) => ({
    event: 'IMC_GENERAL_CONSENT',
    event_type: 'internal',
    consent_mandatory: action.mandatory ? 1 : 0,
    consent_analytics: action.analytics ? 1 : 0,
    consent_marketing: action.marketing ? 1 : 0
  })
}

const loginEvents = {
  SHOW_LOGIN: (_action, _prevState, _nextState) => ({
    event: 'IMC_AUTH_REQUESTED',
    event_type: 'internal',
    event_category: 'Authentication',
    event_action: 'Displayed',
    event_label: 'Login form displayed',
    event_value: 1
  }),

  CLOSE_LOGIN: (_action, _prevState, _nextState) => ({
    event: 'IMC_AUTH_DISMISSED',
    event_type: 'internal',
    event_category: 'Authentication',
    event_action: 'Login Dismissed',
    event_label: 'Login form closed without login',
    event_value: 1
  }),

  LOGIN_SUCCESS: (action, _prevState, _nextState) => {
    const { user } = action
    const { role } = user

    return {
      event: 'IMC_AUTH_SUCCEED',
      event_type: 'public',
      event_category: 'Authentication',
      event_action: 'Login Succeed',
      event_label: 'Login Succeed',
      event_value: 1,
      user_id: user.id,
      user_email: user.email,
      user_name: `${user.first_name} ${user.last_name}`,
      user_company: user.company_name,
      user_role: role.name
    }
  },

  USER_LOG_OUT: (_action, _prevState, _nextState) => ({
    event: 'IMC_AUTH_LOGOUT',
    event_type: 'internal',
    event_category: 'Authentication',
    event_action: 'Logout succeed',
    event_label: 'Logout Success',
    event_value: 1,
    user_id: null,
    user_email: null,
    user_name: null,
    user_company: null,
    user_role: null
  })
}

const shipmentEvents = {

  NEW_SHIPMENT_SUCCESS: (action, _prevState, _nextState) => ({
    event: 'IMC_SHIPMENT_DESTINATION',
    event_type: 'public',
    event_category: 'Shipment',
    event_action: 'Destination and Volumes',
    event_label: 'Choose Shipment Destination and Cargo Itens',
    event_value: 1,
    shipment_id: action.shipmentData.shipment.id
  }),

  CHOOSE_OFFER_REQUEST: (_action, _prevState, nextState) => ({
    event: 'IMC_SHIPMENT_OFFERS_SELECTED',
    event_type: 'public',
    event_category: 'Shipment',
    event_action: 'Offer Selected',
    event_label: 'click',
    event_value: 1,
    shipment_id: nextState.bookingData.activeShipment
  }),

  DOWNLOAD_REQUEST: (_action, _prevState, nextState) => ({
    event: 'IMC_SHIPMENT_OFFERS_DOWNLOAD',
    event_type: 'public',
    event_category: 'Shipment',
    event_action: 'Offers Download',
    event_label: 'click',
    event_value: 1,
    shipment_id: nextState.bookingData.activeShipment
  }),

  SEND_QUOTES_REQUEST: (_action, _prevState, nextState) => ({
    event: 'IMC_SHIPMENT_OFFERS_SEND_EMAIL',
    event_type: 'public',
    event_category: 'Shipment',
    event_action: 'Offers Send by Email',
    event_label: 'click',
    event_value: 1,
    shipment_id: nextState.bookingData.activeShipment
  }),

  FINAL_DETAILS_SELECT_RECEIVER: (_action, _prevState, nextState) => ({ // NOK
    event: 'IMC_SHIPMENT_SELECT_RECEIVER',
    event_type: 'internal',
    event_category: 'Shipment',
    event_action: 'Select Receiver',
    event_label: 'Final details page select receiver click',
    event_value: 1,
    shipment_id: nextState.bookingProcess.id
  }),

  FINAL_DETAILS_SELECT_SENDER: (_action, _prevState, nextState) => ({ // NOK
    event: 'IMC_SHIPMENT_SELECT_SENDER',
    event_type: 'internal',
    event_category: 'Shipment',
    event_action: 'Select sender',
    event_label: 'Final details page, select sender',
    event_value: 1,
    shipment_id: nextState.bookingProcess.id
  }),

  SHIPMENTS_DETAILS_SCROLL: (_action, _prevState, nextState) => ({
    event: 'IMC_SHIPMENT_DETAILS_SCROLL',
    event_type: 'internal',
    event_category: 'Shipment',
    event_action: 'Details Scroll',
    event_label: 'Shipment details Page Scroll',
    event_value: 1,
    shipment_id: nextState.bookingData.activeShipment
  }),

  CHOOSE_OFFER_SCROLL: (_action, _prevState, nextState) => ({
    event: 'IMC_SHIPMENT_CHOOSE_OFFER_SCROLL',
    event_type: 'internal',
    event_category: 'Shipment',
    event_action: 'Choose Offer Scroll',
    event_label: 'Choose offer Page Scroll',
    event_value: 1,
    shipment_id: nextState.bookingData.activeShipment
  }),

  FINAL_DETAILS_SCROLL: (_action, _prevState, nextState) => ({
    event: 'IMC_SHIPMENT_FINAL_DETAILS_SCROLL',
    event_type: 'internal',
    event_category: 'Shipment',
    event_action: 'Final Details Scroll',
    event_label: 'Final details Page Scroll',
    event_value: 1,
    shipment_id: nextState.bookingData.activeShipment
  }),

  COMPLETE_BOOKING_SCROLL: (_action, _prevState, nextState) => ({
    event: 'IMC_COMPLETE_BOOKING_SCROLL',
    event_type: 'internal',
    event_category: 'Shipment',
    event_action: 'Complete Booking Scroll',
    event_label: 'Complete booking Page Scroll',
    event_value: 1,
    shipment_id: nextState.bookingData.activeShipment
  }),

  BOOKING_FINISHED_SCROLL: (_action, _prevState, nextState) => ({
    event: 'IMC_SHIPMENT_BOOKING_FINISHED_SCROLL',
    event_type: 'internal',
    event_category: 'Shipment',
    event_action: 'Booking Finished Scroll',
    event_label: 'Booking finished Page Scroll',
    event_value: 1,
    shipment_id: nextState.bookingData.activeShipment
  }),

  [LOCATION_CHANGE]: (action, _prevState, nextState) => {
    const shipmentId = nextState.bookingProcess.shipment.id

    const mapping = {
      '/booking': ({
        event: 'IMC_SHIPMENT_CARGO_TYPE',
        event_type: 'public',
        event_category: 'Shipment',
        event_action: 'New Shipment',
        event_label: 'Choose Shipment Type (LCL/FCL)',
        event_value: 1,
        shipment_id: null
      }),

      [`/booking/${shipmentId}/shipment_details`]: {
        event: 'IMC_SHIPMENT_DETAILS_PAGEVIEW',
        event_type: 'public',
        event_category: 'Shipment',
        event_action: 'Details Page View',
        event_label: 'Booking details Page View',
        event_value: 1,
        shipment_id: shipmentId
      },

      [`/booking/${shipmentId}/choose_offer`]: ({
        event: 'IMC_SHIPMENT_CHOOSE_OFFER_PAGEVIEW',
        event_type: 'public',
        event_category: 'Shipment',
        event_action: 'Choose Offer Page View',
        event_label: 'Booking finished Page View',
        event_value: 1,
        shipment_id: shipmentId
      }),

      [`/booking/${shipmentId}/final_details`]: ({
        event: 'IMC_SHIPMENT_FINAL_DETAILS_PAGEVIEW',
        event_type: 'public',
        event_category: 'Shipment',
        event_action: 'Final Details Page View',
        event_label: 'Final Details Page View',
        event_value: 1,
        shipment_id: shipmentId
      }),

      [`/booking/${shipmentId}/finish_booking`]: ({
        event: 'IMC_COMPLETE_BOOKING_PAGEVIEW',
        event_type: 'public',
        event_category: 'Shipment',
        event_action: 'Complete Booking Page View',
        event_label: 'Complete booking Page View',
        event_value: 1,
        shipment_id: shipmentId
      }),

      [`/booking/${shipmentId}/thank_you`]: ({
        event: 'IMC_SHIPMENT_FINISHED_PAGEVIEW',
        event_type: 'public',
        event_category: 'Shipment',
        event_action: 'Finished Page View',
        event_label: 'Booking finished Page View',
        event_value: 1,
        shipment_id: shipmentId
      })
    }

    return mapping[action.payload.pathname] || []
  }
}

const allEvents = {
  ...generalEvents,
  ...loginEvents,
  ...shipmentEvents
}

const googleTagManager = new GoogleTagManager(loginEvents)
const beaconMiddleWare = createMiddleware(allEvents, googleTagManager.handleEvents, {
  logger
})

export default beaconMiddleWare
