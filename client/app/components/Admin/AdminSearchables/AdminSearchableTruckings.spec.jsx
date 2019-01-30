import * as React from 'react'
import { range } from 'lodash'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mock'

import AdminSearchableTruckings from './AdminSearchableTruckings'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  shipments: [],
  handleClick: identity,
  adminDispatch: {
    getHub: identity,
    goTo: identity
  },
  seeAll: identity,
  theme,
  limit: 0,
  userView: false,
  title: 'TITLE',
  truckings: [],
  showTooltip: false,
  icon: 'ICON',
  tooltip: 'TOOLTIP'
}

test('shallow render', () => {
  expect(shallow(<AdminSearchableTruckings {...propsBase} />)).toMatchSnapshot()
})

test('when truckings.length < 3', () => {
  const truckings = [{
    nexus: 'NEXUS_0',
    trucking: { _id: 'TRUCKING_ID_0' }
  }]
  const props = {
    ...propsBase,
    truckings
  }
  expect(shallow(<AdminSearchableTruckings {...props} />)).toMatchSnapshot()
})

test('when truckings.length > 3', () => {
  const truckings = range(0, 5).map(i => ({
    nexus: `NEXUS_${i}`,
    trucking: { _id: `TRUCKING_ID_${i}` }
  }))

  const props = {
    ...propsBase,
    truckings
  }
  expect(shallow(<AdminSearchableTruckings {...props} />)).toMatchSnapshot()
})

test('when showTooltip is false', () => {
  const props = {
    ...propsBase,
    showTooltip: false
  }
  expect(shallow(<AdminSearchableTruckings {...props} />)).toMatchSnapshot()
})

test('when icon is empty string', () => {
  const props = {
    ...propsBase,
    icon: ''
  }
  expect(shallow(<AdminSearchableTruckings {...props} />)).toMatchSnapshot()
})
