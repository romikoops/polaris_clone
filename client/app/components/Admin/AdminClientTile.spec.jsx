import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, client } from '../../mock'

import AdminClientTile from './AdminClientTile'

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
  client,
  deleteable: false,
  handleClick: identity,
  tooltip: '',
  showTooltip: false,
  navFn: identity,
  deleteFn: identity,
  target: '',
  flexClasses: 'flex-xs-100 flex-sm-50 flex-md-50 flex-lg-33',
  handleCollapser: identity
}

test('shallow render', () => {
  expect(shallow(<AdminClientTile {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }

  expect(shallow(<AdminClientTile {...props} />)).toMatchSnapshot()
})

test('client is falsy', () => {
  const props = {
    ...propsBase,
    client: null
  }

  expect(shallow(<AdminClientTile {...props} />)).toMatchSnapshot()
})

test('deleteable is true', () => {
  const props = {
    ...propsBase,
    deleteable: true
  }

  expect(shallow(<AdminClientTile {...props} />)).toMatchSnapshot()
})

test('showTooltip is true', () => {
  const props = {
    ...propsBase,
    showTooltip: true
  }

  expect(shallow(<AdminClientTile {...props} />)).toMatchSnapshot()
})

test('state.showDelete is true', () => {
  const wrapper = shallow(<AdminClientTile {...propsBase} />)
  wrapper.setState({ showDelete: true })

  expect(wrapper).toMatchSnapshot()
})
