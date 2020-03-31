import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, hub, tenant
} from '../../../mock'

import AdminHubsComp from './AdminHubsComp'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const propsBase = {
  theme,
  hubs: [hub],
  tenant,
  loading: false,
  countries: [],
  numHubPages: 1,
  appDispatch: {
    fetchCountries: identity
  },
  adminDispatch: {
    getHubs: identity,
  },
  actionNodes: [
    <div>a</div>,
    <div>b</div>
  ],
  handleClick: identity
}

test('shallow render', () => {
  expect(shallow(<AdminHubsComp {...propsBase} />)).toMatchSnapshot()
})

test('countries is truthy', () => {
  const props = {
    ...propsBase,
    countries: [
      { name: 'Germany', id: 0 },
      { name: 'China', id: 3 }
    ]
  }

  expect(shallow(<AdminHubsComp {...props} />)).toMatchSnapshot()
})

test('hubs is falsy', () => {
  const props = {
    ...propsBase,
    hubs: null
  }
  expect(shallow(<AdminHubsComp {...props} />)).toMatchSnapshot()
})

test('state.searchFilters.hubType is truthy', () => {
  const searchFilters = {
    hubType: {
      foo: { a: 1 },
      bar: { b: 2 }
    },
    status: {
      active: true,
      inactive: false
    },
    countries: []
  }
  const wrapper = shallow(<AdminHubsComp {...propsBase} />)
  wrapper.setState({ searchFilters })

  expect(wrapper).toMatchSnapshot()
})

test('state.page > 0', () => {
  const wrapper = shallow(<AdminHubsComp {...propsBase} />)
  wrapper.setState({ page: 2 })

  expect(wrapper).toMatchSnapshot()
})
