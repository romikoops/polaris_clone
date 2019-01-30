import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, user, identity, tenant
} from '../../mocks'

import ButtonSection from './ButtonSection'

const propsBase = {
  bookNow: identity,
  tenant,
  theme,
  user
}

test('shallow render', () => {
  expect(shallow(<ButtonSection {...propsBase} />)).toMatchSnapshot()
})
