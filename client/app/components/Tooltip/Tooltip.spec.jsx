import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks/index'

import { Tooltip } from './Tooltip'

const propsBase = {
  theme,
  text: 'TEXT',
  icon: 'ICON',
  color: 'COLOR',
  toolText: 'TOOLTEXT',
  wrapperClassName: 'WRAPPER_CLASSNAME'
}

test('shallow render', () => {
  expect(shallow(<Tooltip {...propsBase} />)).toMatchSnapshot()
})

test('color is falsy', () => {
  const props = {
    ...propsBase,
    color: null
  }
  expect(shallow(<Tooltip {...props} />)).toMatchSnapshot()
})
