import * as React from 'react'
import { shallow } from 'enzyme'
import { group } from '../../../../../mocks/index'

import CargoItemGroupAggregated from '.'

test('shallow render', () => {
  const props = {
    group
  }
  expect(shallow(<CargoItemGroupAggregated {...props} />)).toMatchSnapshot()
})

test('group.payload_in_kg is falsy', () => {
  const props = {
    group: {
      ...group,
      payload_in_kg: null
    }
  }
  expect(shallow(<CargoItemGroupAggregated {...props} />)).toMatchSnapshot()
})

test('size_class is falsy', () => {
  const props = {
    group: {
      ...group,
      size_class: null
    }
  }
  expect(shallow(<CargoItemGroupAggregated {...props} />)).toMatchSnapshot()
})
