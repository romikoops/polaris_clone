import { errorConstants } from '../constants'

export default function error (state = {}, action) {
  switch (action.type) {
    case errorConstants.SET_ERROR:
      return {
        ...state,
        [action.payload.componentName]: action.payload
      }
    case errorConstants.CLEAR_ERROR: {
      const { [action.payload.componentName]: deletedKey, ...newState } = state

      return newState
    }
    default:
      return state
  }
}
