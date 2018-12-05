import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'
import AdminSearchableShipments from './AdminSearchableShipments'

const propsBase = {
  shipments: [],
  handleClick: identity,
  dispatches: {
    getClient: identity,
    goTo: identity
  },
  showTooltip: false,
  seeAll: false,
  theme,
  limit: 0,
  userView: false,
  title: 'TITLE'
}

test('shallow render', () => {
  expect(shallow(<AdminSearchableShipments {...propsBase} />)).toMatchSnapshot()
})

test('title is empty string', () => {
  const props = {
    ...propsBase,
    title: ''
  }
  expect(shallow(<AdminSearchableShipments {...props} />)).toMatchSnapshot()
})

test('seeAll is true', () => {
  const props = {
    ...propsBase,
    seeAll: true
  }
  expect(shallow(<AdminSearchableShipments {...props} />)).toMatchSnapshot()
})
