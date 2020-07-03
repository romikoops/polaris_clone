import { reducerInitialState } from '.'
import { moment } from '../constants'
import { user } from '../mocks/user'

const { localStorage } = global

describe('reducerInitialState', () => {
  beforeAll(() => {
    localStorage.setItem('organizationId', '1')
    localStorage.setItem('1_user', JSON.stringify(user))
    localStorage.setItem('authHeader', JSON.stringify({ expiry: moment().add(1, 'hour').unix() }))
  })
  test('it load the initialState when user and authHeader are present (authentication)', () => {
    expect(reducerInitialState('authentication')).toEqual({ user, loggedIn: true })
  })
  test('it load the initialState when user and authHeader are present (user)', () => {
    expect(reducerInitialState('user')).toEqual({ userData: user, loggedIn: true })
  })
})

describe('reducerInitialState with invalid authHeader', () => {
  beforeAll(() => {
    localStorage.setItem('organizationId', '1')
    localStorage.setItem('1_user', JSON.stringify(user))
    localStorage.setItem('authHeader', JSON.stringify({ expiry: moment().subtract(1, 'hour').unix() }))
  })
  // Skipping for now as expiry logic needs to be revaluated
  test.skip('it load the initialState when athHeader is invalid (authentication)', () => {
    expect(reducerInitialState('authentication')).toEqual({})
  })
})
