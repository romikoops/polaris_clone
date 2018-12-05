import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../../mocks'
import AdminSearchableHubs from './AdminSearchableHubs'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  hubs: [],
  handleClick: identity,
  adminDispatch: {
    getHub: identity,
    goTo: identity
  },
  seeAll: identity,
  theme,
  sideScroll: false,
  hideFilters: false,
  limit: 0
}

test('shallow render', () => {
  expect(shallow(<AdminSearchableHubs {...propsBase} />)).toMatchSnapshot()
})

test('limit is 1', () => {
  const props = {
    ...propsBase,
    limit: 1
  }
  expect(shallow(<AdminSearchableHubs {...props} />)).toMatchSnapshot()
})

test('hubs is truthy', () => {
  const props = {
    ...propsBase,
    hubs: [hub]
  }
  expect(shallow(<AdminSearchableHubs {...props} />)).toMatchSnapshot()
})

test('when seeAll is falsy', () => {
  const props = {
    ...propsBase,
    seeAll: false
  }
  expect(shallow(<AdminSearchableHubs {...props} />)).toMatchSnapshot()
})

test('when sideScroll is true', () => {
  const props = {
    ...propsBase,
    sideScroll: true
  }
  expect(shallow(<AdminSearchableHubs {...props} />)).toMatchSnapshot()
})
