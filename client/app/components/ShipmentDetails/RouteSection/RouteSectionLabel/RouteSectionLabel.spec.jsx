import * as React from 'react'
import { shallow } from 'enzyme'

import RouteSectionLabel from './RouteSectionLabel'

test('text should be pick-up if target is origin and trucktypes exist', () => {
  const props = {
    truckingOptions: 1,
    target: 'origin'
  }

  const routeSection = shallow(<RouteSectionLabel {...props} />)
  expect(routeSection).toMatchSnapshot()
  expect(routeSection.contains('Pick-up')).toBe(true)
})

test('text should be delivery if target is destination and  trucktypes exist', () => {
  const props = {
    truckingOptions: 1,
    target: 'destination'
  }

  const routeSection = shallow(<RouteSectionLabel {...props} />)
  expect(routeSection).toMatchSnapshot()
  expect(routeSection.contains('Delivery')).toBe(true)
})

test('text should be port-of-loading if target is origin and trucktypes do not exist', () => {
  const props = {
    truckingOptions: 0,
    target: 'origin'
  }

  const routeSection = shallow(<RouteSectionLabel {...props} />)
  expect(routeSection).toMatchSnapshot()
  expect(routeSection.contains('Port of Loading')).toBe(true)
})

test('text should be port-of-discharge if target is destination and trucktypes do not exist', () => {
  const props = {
    truckingOptions: 0,
    target: 'destination'
  }

  const routeSection = shallow(<RouteSectionLabel {...props} />)
  expect(routeSection).toMatchSnapshot()
  expect(routeSection.contains('Port of Discharge')).toBe(true)
})
