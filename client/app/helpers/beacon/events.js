import { get } from 'lodash'

const genericEvents = {
  CONSENT_RECEIVED: (action, state) => {
    if (get(state, 'authentication.user.uuid')) {
      return [
        { hitType: 'alias', userId: get(state, 'authentication.user.uuid') },
        {
          hitType: 'identify',
          userId: get(state, 'authentication.user.uuid'),
          traits: {
            tenant_id: get(state, 'app.tenant.id'),
            tenant: get(state, 'app.tenant.slug'),

            email: get(state, 'authentication.user.email'),
            firstName: get(state, 'authentication.user.first_name'),
            lastName: get(state, 'authentication.user.last_name'),
            role: get(state, 'authentication.user.role.name'),
            companyName: get(state, 'authentication.user.company_name')
          }
        }
      ]
    } else {
      return {
        hitType: 'identify',
        traits: {
          tenant_id: get(state, 'app.tenant.id'),
          tenant: get(state, 'app.tenant.slug')
        }
      }
    }
  }
}

const tenantEvents = {
  SET_TENANT_SUCCESS: (action, state) => ({
    hitType: 'identify',
    traits: {
      tenant_id: get(state, 'app.tenant.id'),
      tenant: get(state, 'app.tenant.slug')
    }
  })
}

const userEvents = {
  SET_USER: (action, state) => {
    if (!get(state, 'authentication.user.uuid')) { return null }

    return [
      { hitType: 'alias', userId: get(state, 'authentication.user.uuid') },
      {
        hitType: 'identify',
        userId: get(state, 'authentication.user.uuid'),
        traits: {
          tenant_id: get(state, 'app.tenant.id'),
          tenant: get(state, 'app.tenant.slug'),

          email: get(state, 'authentication.user.email'),
          firstName: get(state, 'authentication.user.first_name'),
          lastName: get(state, 'authentication.user.last_name'),
          role: get(state, 'authentication.user.role.name'),
          companyName: get(state, 'authentication.user.company_name')
        }
      }
    ]
  },

  USER_LOG_OUT: (action, state) => ({ hitType: 'reset' })
}

const navigationEvents = {
  '@@router/LOCATION_CHANGE': (action, state) => ({
    hitType: 'pageview',
    properties: {
      path: action.payload.pathname
    }
  })
}

const offerEvents = {
  GET_OFFERS_REQUEST: (action, state) => ({
    hitType: 'event',
    eventAction: 'Products Searched',
    properties: {
      cargoType: get(state, 'bookingProcess.shipment.loadType') === 'cargo_item' ? 'LCL' : 'FCL',

      originCoordinates: [
        get(state, 'bookingProcess.shipment.origin.longitude'),
        get(state, 'bookingProcess.shipment.origin.latitude')
      ],
      originPort: get(state, 'bookingProcess.shipment.origin.nexusName'),
      originCity: get(state, 'bookingProcess.shipment.origin.city'),
      originPostalCode: get(state, 'bookingProcess.shipment.origin.zipCode'),
      originCountry: get(state, 'bookingProcess.shipment.origin.country'),

      destinationCoordinates: [
        get(state, 'bookingProcess.shipment.destination.longitude'),
        get(state, 'bookingProcess.shipment.destination.latitude')
      ],
      destinationPort: get(state, 'bookingProcess.shipment.destination.nexusName'),
      destinationCity: get(state, 'bookingProcess.shipment.destination.city'),
      destinationPostalCode: get(state, 'bookingProcess.shipment.destination.zipCode'),
      destinationCountry: get(state, 'bookingProcess.shipment.destination.country')
    }
  })
}

const adminEvents = {
  UPLOAD_REQUEST: (action, state) => ({ hitType: 'event', eventAction: 'Upload Requested' }),
  UPLOAD_SUCCESS: (action, state) => ({
    hitType: 'event',
    eventAction: 'Upload Complete',
    properties: {
      success: !action.payload.has_errors
    }
  })
}

const eventsMap = {
  ...genericEvents,
  ...adminEvents,
  ...navigationEvents,
  ...offerEvents,
  ...tenantEvents,
  ...userEvents
}

export default eventsMap
