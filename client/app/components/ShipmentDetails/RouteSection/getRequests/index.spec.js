/* eslint-disable jest/valid-expect */
import getRequests from '.'

const { fetch } = global
describe('counterpartCountries', () => {
  const target = 'origin'
  const mockCountries = [{ flag: 'xxx', code: 'DE', name: 'Germany' }]

  test('it returns an array of countries', () => {
    fetch.mockResponses(
      [
        JSON.stringify({ data: mockCountries }),
        { status: 200 }
      ]
    )
    expect(getRequests.counterpartCountries(target, {})).resolves.toEqual(mockCountries)
  })

  test('it returns an empty array of countries', () => {
    fetch.mockResponses(
      [
        JSON.stringify({}),
        { status: 200 }
      ]
    )
    expect(getRequests.counterpartCountries(target, {})).resolves.toEqual([])
  })
})

describe('findAvailability', () => {
  const lat = 1.111
  const lng = 2.222
  const loadType = 'cargo_item'
  const carriage = 'pre'
  const availableHubIds = [1]
  const callback = (x, y) => ({ truckingAvailable: x, hubIds: y })

  test('it returns an postive result', () => {
    const expectedResponse = { truckingAvailable: true, hubIds: [2] }

    fetch.mockResponses(
      [
        JSON.stringify({ data: expectedResponse }),
        { status: 200 }
      ]
    )
    expect(
      getRequests.findAvailability(lat, lng, loadType, carriage, availableHubIds, callback)
    ).resolves.toEqual(expectedResponse)
  })
  test('it returns an negative result', () => {
    const expectedResponse = { truckingAvailable: false, hubIds: [] }

    fetch.mockResponses(
      [
        JSON.stringify({}),
        { status: 200 }
      ]
    )
    expect(
      getRequests.findAvailability(lat, lng, loadType, carriage, availableHubIds, callback)
    ).resolves.toEqual(expectedResponse)
  })
  test('it returns an negative result when catching an error', () => {
    const expectedResponse = { truckingAvailable: false, hubIds: [] }

    fetch.mockResponses(
      [
        'error',
        { status: 400 }
      ]
    )
    expect(
      getRequests.findAvailability(lat, lng, loadType, carriage, availableHubIds, callback)
    ).resolves.toEqual(expectedResponse)
  })
})
