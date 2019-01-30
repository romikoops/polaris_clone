import * as React from 'react'
import { shallow } from 'enzyme'
import { change } from '../../mock'
import AdminShipmentStatus from './AdminShipmentStatus'

const propsBase = {
  shipments: {
    open: [],
    requested: [],
    finished: [],
    archived: [],
    rejected: []
  }
}

test('shallow render', () => {
  expect(shallow(<AdminShipmentStatus {...propsBase} />)).toMatchSnapshot()
})

test('open is falsy', () => {
  const props = change(
    propsBase,
    'shipments.open',
    null
  )
  expect(shallow(<AdminShipmentStatus {...props} />)).toMatchSnapshot()
})

test('requested is falsy', () => {
  const props = change(
    propsBase,
    'shipments.requested',
    null
  )
  expect(shallow(<AdminShipmentStatus {...props} />)).toMatchSnapshot()
})

test('finished is falsy', () => {
  const props = change(
    propsBase,
    'shipments.finished',
    null
  )
  expect(shallow(<AdminShipmentStatus {...props} />)).toMatchSnapshot()
})

test('archived is falsy', () => {
  const props = change(
    propsBase,
    'shipments.archived',
    null
  )
  expect(shallow(<AdminShipmentStatus {...props} />)).toMatchSnapshot()
})

test('rejected is falsy', () => {
  const props = change(
    propsBase,
    'shipments.rejected',
    null
  )
  expect(shallow(<AdminShipmentStatus {...props} />)).toMatchSnapshot()
})
