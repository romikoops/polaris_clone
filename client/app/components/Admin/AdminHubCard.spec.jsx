import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, hub } from '../../mock'

import AdminHubCard from './AdminHubCard'

const propsBase = {
  theme,
  adminDispatch: {},
  hubs: { foo: hub }
}

test('shallow render', () => {
  expect(shallow(<AdminHubCard {...propsBase} />)).toMatchSnapshot()
})

test('hubs is falsy', () => {
  const props = {
    ...propsBase,
    hubs: {}
  }

  expect(shallow(<AdminHubCard {...props} />)).toMatchSnapshot()
})
