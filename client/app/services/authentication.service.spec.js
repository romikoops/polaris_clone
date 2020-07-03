import authenticationService from './authentication.service'

describe('#changePassword', () => {
  beforeEach(() => {

  })

  it('calls the corrent endpoint', () => {
    expect.assertions(1)
    window.fetch.mockResponseOnce('{}')

    const expectedUrl = 'http://api.itsmytest.com/password_resets'
    const expectedRequest = {
      body: '{"email":"email@itsmytest.com","redirect_url":"http://itsmytest.com"}',
      headers: { 'Content-Type': 'application/json' },
      method: 'POST'
    }

    const request = authenticationService.changePassword('email@itsmytest.com', 'http://itsmytest.com')

    return request.then(() => {
      expect(window.fetch).toHaveBeenCalledWith(expectedUrl, expectedRequest)
    })
  })
})

jest.mock('../constants/api.constants', () => {
  const actual = jest.requireActual('../constants/api.constants')

  return {
    ...actual,
    getTenantApiUrl: () => 'http://api.itsmytest.com'
  }
})
