import { userService } from './user.service'

describe('#confirmAccount', () => {
  it('calls the corrent endpoint', () => {
    expect.assertions(1)
    window.fetch.mockResponseOnce('{}')

    const expectedUrl = 'http://api.itsmytest.com/users/NICE-TOKEN/activate'

    return userService.confirmAccount('NICE-TOKEN').then(() => {
      expect(window.fetch).toHaveBeenCalledWith(expectedUrl)
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
