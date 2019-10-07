import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, user, identity, tenant
} from '../../mocks/index'

import LandingVideo from './LandingVideo'

const propsBase = {
}

test('shallow render', () => {
  expect(shallow(<LandingVideo {...propsBase} />)).toMatchSnapshot()
})
