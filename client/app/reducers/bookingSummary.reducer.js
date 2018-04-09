import { bookingSummaryConstants } from '../constants'

export default function bookingSummary (state = {}, action) {
  switch (action.type) {
    case bookingSummaryConstants.UPDATE:
      return {
        ...state,
        ...action.payload
      }
    default:
      return state
  }
}
