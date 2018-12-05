import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change, theme, identity, hub
} from '../../../mocks'

import AdminHubTile from './AdminHubTile'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const hubBase = {
  ...hub,
  data: {
    name: 'NAME',
    hub_type: 'air'
  }
}

const propsBase = {
  theme,
  hub: hubBase,
  navFn: identity,
  handleClick: identity,
  target: 'IMPORT',
  tooltip: 'TOOLTIP',
  showTooltip: false,
  showIcon: false
}

test('shallow render', () => {
  expect(shallow(<AdminHubTile {...propsBase} />)).toMatchSnapshot()
})

test('hub is falsy', () => {
  const props = {
    ...propsBase,
    prop: null
  }
  expect(shallow(<AdminHubTile {...props} />)).toMatchSnapshot()
})

test('showTooltip is truthy', () => {
  const props = {
    ...propsBase,
    showTooltip: true
  }
  expect(shallow(<AdminHubTile {...props} />)).toMatchSnapshot()
})

test('showIcon is truthy', () => {
  const props = {
    ...propsBase,
    showIcon: true
  }
  expect(shallow(<AdminHubTile {...props} />)).toMatchSnapshot()
})

test('hub.data.photo is truthy', () => {
  const props = change(propsBase, 'hub.data', { photo: 'PHOTO' })

  expect(shallow(<AdminHubTile {...props} />)).toMatchSnapshot()
})

test('hub.data.hub_type is falsy', () => {
  const props = change(propsBase, 'hub.data', { hub_type: null })

  expect(shallow(<AdminHubTile {...props} />)).toMatchSnapshot()
})
