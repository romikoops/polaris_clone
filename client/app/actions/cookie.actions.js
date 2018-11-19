function updateCookieHeight (payload) {
  return (dispatch) => { dispatch({ type: 'UPDATE_COOKIE_HEIGHT', payload }) }
}

const cookieActions = {
  updateCookieHeight
}

export default cookieActions
