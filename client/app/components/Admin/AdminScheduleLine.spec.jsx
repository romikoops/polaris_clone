import * as React from 'react'
import { shallow } from 'enzyme'
import { schedule, theme, change } from '../../mock'

import AdminScheduleLine from './AdminScheduleLine'

jest.mock('../../constants', () => {
  const format = () => 19
  const subtract = () => ({ format })
  const add = () => ({ format })

  const moment = () => ({
    format,
    subtract,
    add
  })

  return { moment }
})

const hub = {
  data: {
    name: 'FOO_NAME',
    hub_code: 'FOO_HUB_CODE'
  },
  name: 'FOO_HUB_NAME'
}
const secondHub = {
  data: {
    name: 'BAR_NAME',
    hub_code: 'BAR_HUB_CODE'
  },
  name: 'BAR_HUB_NAME'
}
const propsBase = {
  theme,
  schedule: {
    ...schedule,
    hub_route_key: '0-1'
  },
  hubs: [hub, secondHub],
  pickupDate: 7
}

test('shallow render', () => {
  expect(shallow(<AdminScheduleLine {...propsBase} />)).toMatchSnapshot()
})

test('schedule is falsy', () => {
  const props = {
    ...propsBase,
    schedule: null
  }
  expect(shallow(<AdminScheduleLine {...props} />)).toMatchSnapshot()
})

test('originHub.hub_code is falsy', () => {
  const changedHub = change(
    hub,
    'data.hub_code',
    null
  )
  const props = {
    ...propsBase,
    hubs: [changedHub, secondHub]
  }
  expect(shallow(<AdminScheduleLine {...props} />)).toMatchSnapshot()
})

test('destHub.hub_code is falsy', () => {
  const changedHub = change(
    secondHub,
    'data.hub_code',
    null
  )
  const props = {
    ...propsBase,
    hubs: [hub, changedHub]
  }
  expect(shallow(<AdminScheduleLine {...props} />)).toMatchSnapshot()
})

test('!hubs[hubKeys[0]]', () => {
  const props = {
    ...propsBase,
    hubs: []
  }
  expect(shallow(<AdminScheduleLine {...props} />)).toMatchSnapshot()
})
