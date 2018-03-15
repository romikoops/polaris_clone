import { documentConstants } from '../constants'

export default function app (state = {}, action) {
  switch (action.type) {
    case documentConstants.UPLOAD_REQUEST: {
      return {
        ...state,
        loading: true
      }
    }
    case documentConstants.UPLOAD_SUCCESS: {
      return {
        ...state,
        loading: false,
        results: action.payload,
        viewer: true
      }
    }
    case documentConstants.UPLOAD_FAILURE: {
      return {
        ...state,
        error: action.payload
      }
    }
    case documentConstants.CLOSE_VIEWER: {
      return {
        ...state,
        viewer: false
      }
    }

    default:
      return state
  }
}
