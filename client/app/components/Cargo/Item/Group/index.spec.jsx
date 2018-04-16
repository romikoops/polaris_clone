import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../../mocks'

jest.mock('../../../../helpers', () => ({
  gradientTextGenerator: x => x
}))
jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('./Aggregated', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../../../HsCodes/HsCodeViewer', () => ({
  // eslint-disable-next-line react/prop-types
  HsCodeViewer: ({ children }) => <div>{children}</div>
}))
jest.mock('react-toggle', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
// eslint-disable-next-line
import { CargoItemGroup } from './'

const group = {
  quantity: 'FOO_QUANTITY',
  size_class: 'dry_goods',
  cargoType: {
    category: 'FOO_CATEGORY'
  },
  items: [{
    chargeable_weight: 80,
    dimension_x: 90,
    dimension_y: 100,
    dimension_z: 120,
    payload_in_kg: 56,
    tare_weight: 20,
    gross_weight: 76
  }]
}

const propsBase = {
  theme,
  group,
  viewHSCodes: false,
  hsCodes: ['FOO_HSCODE', 'BAR_HSCODE']
}

test('shallow render', () => {
  expect(shallow(<CargoItemGroup {...propsBase} />)).toMatchSnapshot()
})

test('props.viewHSCodes is true', () => {
  const props = {
    ...propsBase,
    viewHSCodes: true
  }
  expect(shallow(<CargoItemGroup {...props} />)).toMatchSnapshot()
})
