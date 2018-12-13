import { errorConstants } from '../constants'

export default function error (state = {}, action) {
  switch (action.type) {
   
      case errorConstants.SET_ERROR:
      return {
        ...state,
        [action.payload.componentName]: action.payload
      }
    case errorConstants.ERROR: {
      const newState = state
      delete newState[action.payload.componentName]

      return newState
    }
    default:
      return state
  }
}
