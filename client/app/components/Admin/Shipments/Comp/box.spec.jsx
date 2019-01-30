import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../../mock'

import AdminShipmentsBox from './box'

const propsBase = {
  shipments: [],
  handleClick: null,
  seeAll: null,
  theme,
  confirmShipmentData: {},
  userView: false,
  page: 1,
  nextPage: null,
  prevPage: null,
  handleSearchChange: null,
  numPages: 1
}

test('shallow render', () => {
  expect(shallow(<AdminShipmentsBox {...propsBase} />)).toMatchSnapshot()
})

test('page > 10', () => {
  const props = {
    ...propsBase,
    page: 11
  }
  expect(shallow(<AdminShipmentsBox {...props} />)).toMatchSnapshot()
})

test('shipments is truthy', () => {
  const props = {
    ...propsBase,
    shipments: [{}]
  }
  expect(shallow(<AdminShipmentsBox {...props} />)).toMatchSnapshot()
})
