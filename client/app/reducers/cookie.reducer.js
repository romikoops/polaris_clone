export default function cookie (state = {}, action) {
  switch (action.type) {
    case 'UPDATE_COOKIE_HEIGHT':
      return {
        ...state,
        ...action.payload
      }
    default:
      return state
  }
}
