import * as React from 'react'
import { shallow } from 'enzyme'
import { tenant, user, theme, identity } from '../../mocks'
// eslint-disable-next-line
import Tenant from './Tenant'

const propsBase = {
  user,
  theme,
  tenant,
  userDispatch: {
    optOut: identity
  }
}

test('shallow rendering', () => {
  expect(shallow(<Tenant {...propsBase} />)).toMatchSnapshot()
})
