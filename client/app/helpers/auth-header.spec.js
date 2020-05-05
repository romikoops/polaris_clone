import { authHeader } from './auth-header'
import { moment } from '../constants'

const { localStorage } = global

describe('authHeader valid no sandbox', () => {
  let dummyAuth
  beforeAll(() => {
    dummyAuth = {
      expiry: moment().add(1, 'hour').unix(),
      client: '1234',
      uid: '1234567890',
      'access-token': 'qwertyuiop',
      'token-type': 'Bearer'
    }
    localStorage.setItem('authHeader', JSON.stringify(dummyAuth))
  })
  test('it should return the authHeader', () => {
    expect(authHeader()).toEqual({ ...dummyAuth, sandbox: null })
  })
})

describe('authHeader valid with sandbox', () => {
  let dummyAuth
  beforeAll(() => {
    dummyAuth = {
      expiry: moment().add(1, 'hour').unix(),
      client: '1234',
      uid: '1234567890',
      'access-token': 'qwertyuiop',
      'token-type': 'Bearer'
    }
    localStorage.setItem('authHeader', JSON.stringify(dummyAuth))
    localStorage.setItem('sandbox', 'sandboxid')
  })
  test('it should return the authHeader', () => {
    expect(authHeader()).toEqual({ ...dummyAuth, sandbox: 'sandboxid' })
  })
})

describe('authHeader invalid', () => {
  let dummyAuth
  beforeAll(() => {
    dummyAuth = {
      expiry: moment().subtract(1, 'hour').unix(),
      client: '1234',
      uid: '1234567890',
      'access-token': 'qwertyuiop',
      'token-type': 'Bearer'
    }
    localStorage.setItem('authHeader', JSON.stringify(dummyAuth))
    localStorage.setItem('sandbox', 'sandboxid')
  })
  test('it should return the authHeader', () => {
    expect(authHeader()).toEqual({})
  })
})
