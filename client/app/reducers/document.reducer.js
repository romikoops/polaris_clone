import { documentConstants } from '../constants'

export default function app (state = {}, action) {
  switch (action.type) {
    case documentConstants.UPLOAD_PRICINGS_REQUEST: {
      return {
        ...state,
        loading: true
      }
    }
    case documentConstants.UPLOAD_PRICINGS_SUCCESS: {
      return {
        ...state,
        loading: false,
        results: action.payload,
        viewer: true
      }
    }
    case documentConstants.UPLOAD_PRICINGS_FAILURE: {
      return {
        ...state,
        error: action.payload
      }
    }

    default:
      return state
  }
}
