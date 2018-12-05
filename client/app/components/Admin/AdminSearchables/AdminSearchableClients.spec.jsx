import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'
import AdminSearchableClients from './AdminSearchableClients'

const propsBase = {
  clients: [],
  handleClick: identity,
  adminDispatch: {
    getClient: identity,
    goTo: identity
  },
  seeAll: identity,
  placeholder: 'PLACEHOLDER',
  theme,
  showTooltip: false,
  tooltip: 'TOOLTIP',
  hideFilters: false,
  title: 'TITLE'
}

test('shallow render', () => {
  expect(shallow(<AdminSearchableClients {...propsBase} />)).toMatchSnapshot()
})

test('placeholder is falsy', () => {
  const props = {
    ...propsBase,
    placeholder: null
  }
  expect(shallow(<AdminSearchableClients {...props} />)).toMatchSnapshot()
})

test('title is falsy', () => {
  const props = {
    ...propsBase,
    title: null
  }
  expect(shallow(<AdminSearchableClients {...props} />)).toMatchSnapshot()
})

test('showTooltip and hideFilters are true', () => {
  const props = {
    ...propsBase,
    showTooltip: true,
    hideFilters: true
  }
  expect(shallow(<AdminSearchableClients {...props} />)).toMatchSnapshot()
})
