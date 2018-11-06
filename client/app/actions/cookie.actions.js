function updateCookieHeight (height) {
  return (dispatch) => { dispatch({ type: 'UPDATE_COOKIE_HEIGHT', payload: height }) }
}

const cookieActions = {
  updateCookieHeight
}

export default cookieActions
