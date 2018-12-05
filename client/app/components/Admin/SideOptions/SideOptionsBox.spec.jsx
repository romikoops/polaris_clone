import * as React from 'react'
import { shallow } from 'enzyme'

import SideOptionsBox from './SideOptionsBox'

const propsBase = {
  content: 'CONTENT',
  header: 'HEADER',
  flexOptions: 'FLEX_OPTIONS'
}

test('shallow render', () => {
  expect(shallow(<SideOptionsBox {...propsBase} />)).toMatchSnapshot()
})
