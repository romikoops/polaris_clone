import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, user, identity, tenant
} from '../../mocks/index'

import { translatedLandingTop as LandingTop } from './LandingTop'

const propsBase = {
  bookNow: identity,
  goTo: identity,
  tenant,
  theme,
  toAdmin: identity,
  toggleShowLogin: identity,
  user
}

test('shallow render', () => {
  expect(shallow(<LandingTop {...propsBase} />)).toMatchSnapshot()
})

test('theme has truthy properties', () => {
  const editedTheme = {
    ...theme,
    background: 'green',
    logoLarge: 'LOGO_LARGE',
    logoWhite: 'LOGO_WHITE',
    welcome_text: 'WELCOME_TEXT'
  }
  const props = {
    ...propsBase,
    theme: editedTheme
  }
  expect(shallow(<LandingTop {...props} />)).toMatchSnapshot()
})
