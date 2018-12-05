import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../../mocks'

import AdminHubEdit from './AdminHubEdit'

const propsBase = {
  hub,
  close: identity,
  adminDispatch: {},
  theme
}

test('shallow render', () => {
  expect(shallow(<AdminHubEdit {...propsBase} />)).toMatchSnapshot()
})
