import * as React from 'react'
import { shallow } from 'enzyme'
import Dropdown from '.'

const availableTargets = [
  {
    stopId: 4673,
    hubId: 3023,
    hubName: 'Gothenburg Port',
    nexusId: 597,
    nexusName: 'Gothenburg',
    latitude: 57.694253,
    longitude: 11.854048,
    country: 'SE',
    truckTypes: [
      'default'
    ]
  },
  {
    stopId: 33903,
    hubId: 5961,
    hubName: 'Southampton Port',
    nexusId: 3282,
    nexusName: 'Southampton',
    latitude: 50.9097004,
    longitude: -1.4043509,
    country: 'GB',
    truckTypes: [
      'default'
    ]
  }
]

const propsBase = {
  target: 'TARGET',
  availableTargets,
  formData: {},
  onDropdownSelect: x => x
}

test('with empty props', () => {
  expect(() => shallow(<Dropdown />)).toThrow()
})

test('happy path', () => {
  expect(shallow(<Dropdown {...propsBase} />)).toMatchSnapshot()
})
