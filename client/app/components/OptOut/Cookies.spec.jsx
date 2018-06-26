import * as React from 'react'
import { shallow } from 'enzyme'
import { user, theme, identity } from '../../mocks'
// eslint-disable-next-line
import Cookies from './Cookies'

const propsBase = {
  user,
  theme,
  userDispatch: {
    optOut: identity
  }
}

test('shallow rendering', () => {
  expect(shallow(<Cookies {...propsBase} />)).toMatchSnapshot()
})
