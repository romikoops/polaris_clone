import * as React from 'react'
import { shallow } from 'enzyme'
import { tenant, user, theme, identity } from '../../mocks'
// eslint-disable-next-line
import ItsMyCargo from './ItsMyCargo'

const propsBase = {
  user,
  theme,
  tenant,
  userDispatch: {
    optOut: identity
  }
}

test('shallow rendering', () => {
  expect(shallow(<ItsMyCargo {...propsBase} />)).toMatchSnapshot()
})
