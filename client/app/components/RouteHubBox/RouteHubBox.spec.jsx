import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, locations } from '../../mocks'

import { RouteHubBox } from './RouteHubBox'

const hubs = {
  startHub: { location: { geocoded_address: 'FOO_ADDRESS' }, data: { name: 'FOO' } },
  endHub: { location: { geocoded_address: 'BAR_ADDRESS' }, data: { name: 'BAR' } }
}

const propsBase = {
  theme,
  route: [{ eta: 3 }, { etd: 2 }],
  hubs,
  locations
}

const createShallow = propsInput => shallow(<RouteHubBox {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})

test('props.locations is falsy', () => {
  const props = {
    ...propsBase,
    locations: false
  }
  expect(createShallow(props)).toMatchSnapshot()
})
