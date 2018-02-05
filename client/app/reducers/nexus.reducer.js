import merge from 'lodash/merge'
import { nexusConstants } from '../constants'

export default function nexus (state = {}, action) {
  switch (action.type) {
    case nexusConstants.GET_AVAILABLE_DESTINATIONS_REQUEST:
      return {}

    case nexusConstants.GET_AVAILABLE_DESTINATIONS_SUCCESS:
      return { availableDestinations: action.data.available_destinations }

    case nexusConstants.GET_AVAILABLE_DESTINATIONS_FAILURE: {
      const errG = merge({}, state, {
        error: { get: [action.error] }
      })
      return errG
    }

    default:
      return state
  }
}
