import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks'

jest.mock('../../helpers', () => ({
  gradientGenerator: x => x
}))
jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
// eslint-disable-next-line import/first
import { Tooltip } from './Tooltip'

const propsBase = {
  theme,
  text: 'FOO_TEXT',
  icon: 'FOO_ICON',
  color: 'FOO_COLOR',
  toolText: 'FOO_TOOLTEXT',
  wrapperClassName: 'FOO_CLASSNAME'
}

test('shallow render', () => {
  expect(shallow(<Tooltip {...propsBase} />)).toMatchSnapshot()
})
