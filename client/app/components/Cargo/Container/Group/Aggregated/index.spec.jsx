import * as React from 'react'
import { shallow } from 'enzyme'
import { firstCargoItem } from '../../../../../mocks'
import CargoItemGroupAggregated from '.'

test('shallow render', () => {
  const props = {
    group: firstCargoItem
  }
  expect(shallow(<CargoItemGroupAggregated {...props} />)).toMatchSnapshot()
})

test('payload_in_kg is falsy', () => {
  const props = {
    group: {
      ...firstCargoItem,
      payload_in_kg: null
    }
  }
  expect(shallow(<CargoItemGroupAggregated {...props} />)).toMatchSnapshot()
})
