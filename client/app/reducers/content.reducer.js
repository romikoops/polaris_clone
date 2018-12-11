import { contentConstants } from '../constants'

export default function content (state = {}, action) {
  switch (action.type) {
    case contentConstants.COMPONENT_FETCH_REQUEST:  {
      const oldComponents = state.components || {}

      return {
        ...state,
        components: oldComponents
      }
    }
    case contentConstants.COMPONENT_FETCH_SUCCESS: {
      const oldComponents = state.components || {}
      const newComponents = {
        ...oldComponents,
        [action.payload.component]: action.payload.content
      }

      return {
        ...state,
        components: newComponents
      } }
    case contentConstants.COMPONENT_FETCH_ERROR:
      return {
        type: 'alert-danger',
        message: action.message
      }
    case contentConstants.COMPONENT_FETCH_CLEAR:
      return {}
    default:
      return state
  }
}
