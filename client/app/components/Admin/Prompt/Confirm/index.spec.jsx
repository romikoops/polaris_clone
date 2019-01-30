import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../../mock'

import AdminPromptConfirm from '.'

const propsBase = {
  theme,
  heading: 'HEADING',
  text: 'TEXT',
  confirm: identity,
  deny: identity
}

test('shallow render)', () => {
  expect(shallow(<AdminPromptConfirm {...propsBase} />)).toMatchSnapshot()
})
