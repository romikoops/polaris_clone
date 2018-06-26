import * as React from 'react'
import { shallow } from 'enzyme'

import Button from './Button'

const propsBase = {
  text: 'FOO_TEXT'
}

test('shallow render', () => {
  expect(shallow(<Button {...propsBase} />)).toMatchSnapshot()
})
