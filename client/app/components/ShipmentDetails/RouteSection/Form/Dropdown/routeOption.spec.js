import routeOption from './routeOption'

describe('routeOption()', () => {
  const target = {
    country: "CN",
    hubId: 3025,
    hubName: "Shanghai Port",
    latitude: 30.626539,
    longitude: 122.064958,
    nexusId: 599,
    nexusName: "Shanghai",
    stopId: 4628,
    truckTypes: ["default"]
  }
  test('it retruns the route option with country label', () => {
    const result = routeOption(target)
    expect(result.label).toEqual('Shanghai, CN')
  })

  test('it retruns the route option with country label', () => {
    const targetWithoutCountry = {
      ...target,
      country: ""
    }
    const result = routeOption(targetWithoutCountry)
    expect(result.label).toEqual('Shanghai')
  })
})