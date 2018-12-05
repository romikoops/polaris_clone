import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, hub, change
} from '../../../mocks'

import AdminHubView from './AdminHubView'

const hubBase = {
  ...hub,
  hub_type: 'HUB_TYPE',
  hub_status: 'active',
  nexus: {
    name: 'HUB_NEXUS_NAME'
  }
}

const propsBase = {
  theme,
  hubHash: {},
  adminActions: {
    getHub: identity,
    activateHub: identity
  },
  hubData: {
    address: {
      longitude: 'ADDRESS_LONGITUDE',
      latitude: 'ADDRESS_LATITUDE'
    },
    hub: hubBase,
    relatedHubs: [],
    routes: [],
    schedules: [],
    charges: [],
    customs: [],
    serviceLevels: [],
    counterpartHubs: [],
    location: {
      longitude: 'LONGITUDE',
      latitude: 'LATITUDE'
    },
    mandatoryCharges: {}
  }
}

test('shallow render', () => {
  expect(shallow(<AdminHubView {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminHubView {...props} />)).toMatchSnapshot()
})

test('hubData.hub is falsy', () => {
  const props = change(
    propsBase,
    'hubData',
    { hub: null }
  )

  expect(shallow(<AdminHubView {...props} />)).toMatchSnapshot()
})

test('hubData.relatedHubs is truthy', () => {
  const props = change(
    propsBase,
    'hubData',
    { relatedHubs: [hub] }
  )

  expect(shallow(<AdminHubView {...props} />)).toMatchSnapshot()
})

test('hubData.hub.hub_status is inactive', () => {
  const props = change(
    propsBase,
    'hubData.hub',
    { hub_status: 'inactive' }
  )

  expect(shallow(<AdminHubView {...props} />)).toMatchSnapshot()
})

test('hubData.routes is truthy', () => {
  const props = change(
    propsBase,
    'hubData.routes',
    [{}]
  )

  expect(shallow(<AdminHubView {...props} />)).toMatchSnapshot()
})

test('state.confirm is truthy', () => {
  const wrapper = shallow(<AdminHubView {...propsBase} />)
  wrapper.setState({ confirm: true })

  expect(wrapper).toMatchSnapshot()
})

test('state.page > 1', () => {
  const wrapper = shallow(<AdminHubView {...propsBase} />)
  wrapper.setState({ page: 2 })

  expect(wrapper).toMatchSnapshot()
})

test('state.editView is truthy', () => {
  const wrapper = shallow(<AdminHubView {...propsBase} />)
  wrapper.setState({ editView: true })

  expect(wrapper).toMatchSnapshot()
})
