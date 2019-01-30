import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, location } from '../../mock'

import AdminNexusTile from './AdminNexusTile'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  theme,
  nexus: location,
  navFn: identity,
  handleClick: identity,
  target: 'TARGET',
  tooltip: 'TOOLTIP',
  showTooltip: false
}

test('shallow render', () => {
  expect(shallow(<AdminNexusTile {...propsBase} />)).toMatchSnapshot()
})

test('showTooltip is true', () => {
  const props = {
    ...propsBase,
    showTooltip: true
  }
  expect(shallow(<AdminNexusTile {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminNexusTile {...props} />)).toMatchSnapshot()
})

test('nexus is falsy', () => {
  const props = {
    ...propsBase,
    nexus: null
  }
  expect(shallow(<AdminNexusTile {...props} />)).toMatchSnapshot()
})
