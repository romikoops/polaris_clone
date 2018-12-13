import { errorConstants } from '../constants'

function setError (error) {
  return { type: errorConstants.SET_ERROR, payload: error }
}

function clearError (error) {
  return { type: errorConstants.CLEAR_ERROR, payload: error }
}

export const errorActions = {
  setError,
  clearError
}

export default errorActions
