import { isEmpty } from 'lodash'
import { cookieKey, authHeader } from '.'

const { localStorage } = window

function userValues (type, user) {
  if (type === 'authentication') {
    return { user }
  }

  return { userData: user }
}

function userData () {
  const userCookie = localStorage.getItem(cookieKey())

  return (typeof (userCookie) !== 'undefined') && userCookie !== 'undefined' ? JSON.parse(userCookie) : {}
}

export default function reducerInitialState (type) {
  const user = userData()

  return !isEmpty(user) && !isEmpty(authHeader()) ? { loggedIn: true, ...userValues(type, user) } : {}
}
