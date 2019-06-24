import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change, theme, identity, client, hub, location, user
} from '../../../../mock'

import AdminClientView from './'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const managers = [
  {
    id: 7,
    section: 'FOO_SECTION',
    first_name: 'MANAGER_FIRST_NAME',
    last_name: 'MANAGER_LAST_NAME'
  }
]

const propsBase = {
  theme,
  store: {
    getState: () => ({authentication: { user }, clients: {}, app: { tenant: { theme: {}}}}),
    subscribe: () => {}
  },
  hubs: [hub],
  adminDispatch: identity,
  managers,
  handleClick: identity,
  clientData: {
    addresses: [{}],
    managerAssignments: [],
    client,
    shipments: [{}],
    locations: [location]
  }
}

test('shallow render', () => {
  expect(shallow(<AdminClientView {...propsBase} />)).toMatchSnapshot()
})

test('clientData.managerAssignments is falsy', () => {
  const props = change(
    propsBase,
    'clientData',
    { managerAssignments: null }
  )

  expect(shallow(<AdminClientView {...props} />)).toMatchSnapshot()
})

test('clientData is falsy', () => {
  const props = {
    ...propsBase,
    clientData: null
  }

  expect(shallow(<AdminClientView {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }

  expect(shallow(<AdminClientView {...props} />)).toMatchSnapshot()
})

test('managers is falsy', () => {
  const props = {
    ...propsBase,
    managers: []
  }

  expect(shallow(<AdminClientView {...props} />)).toMatchSnapshot()
})

test('managerAssignments is truthy', () => {
  const managerAssignments = [
    { manager_id: 7, section: 'BAZ_SECTION' }
  ]
  const props = change(
    propsBase,
    'clientData.managerAssignments',
    managerAssignments
  )

  expect(shallow(<AdminClientView {...props} />)).toMatchSnapshot()
})

test('state.showAddManager is true', () => {
  const managerAssignments = [
    { manager_id: 7, section: 'BAZ_SECTION' }
  ]
  const props = change(
    propsBase,
    'clientData.managerAssignments',
    managerAssignments
  )
  const wrapper = shallow(<AdminClientView {...props} />)
  wrapper.setState({ showAddManager: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.confirm is true', () => {
  const wrapper = shallow(<AdminClientView {...propsBase} />)
  wrapper.setState({ confirm: true })

  expect(wrapper).toMatchSnapshot()
})
