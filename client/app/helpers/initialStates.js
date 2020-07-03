import { isEmpty } from 'lodash'
import { cookieKey, authHeader } from '.'

const { localStorage } = window

const nilUser = {
  role: {
    name: 'shipper',
    id: 2
  },
  first_name: 'Guest',
  last_name: 'User',
  email: '',
  id: null,
  guest: true,
  lastExpiry: 86400
}

function userValues (type, user) {
  if (type === 'authentication') {
    return { user }
  }

  return { userData: user }
}

function userData () {
  const userCookie = localStorage.getItem(cookieKey())
  const cookieIsValid = !!userCookie && (typeof (userCookie) !== 'undefined') && userCookie !== 'undefined'

  return cookieIsValid ? JSON.parse(userCookie) : nilUser
}

export default function reducerInitialState (type) {
  const user = userData()

  return {
    loggedIn: !isEmpty(user) && !isEmpty(authHeader()),
    ...userValues(type, user)
  }
}
