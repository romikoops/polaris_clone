import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, tenant, shipment } from '../../../mocks'

jest.mock('../../../helpers', () => ({
  gradientTextGenerator: (x, y) =>
    ({ background: `-webkit-linear-gradient(left, ${x},${y})` }),
  determineSpecialism: x => x,
  switchIcon: x => x
}))
// eslint-disable-next-line
import IncotermRow from './'

const editedTenant = {
  ...tenant,
  data: {
    ...tenant.data,
    scope: {
      detailed_billing: true
    }
  }
}
const propsBase = {
  theme,
  feeHash: {
    cargo: {},
    export: { value: 20, currency: 'EUR' },
    import: { value: 9, currency: 'EUR' },
    trucking_on: { value: 3, currency: 'EUR' }
  },
  onCarriage: false,
  preCarriage: false,
  originFees: false,
  destinationFees: false,
  tenant: editedTenant,
  shipment,
  firstStep: false
}

test.skip('shallow render', () => {
  expect(shallow(<IncotermRow {...propsBase} />)).toMatchSnapshot()
})

test.skip('props.feeHash is empty object', () => {
  const props = {
    ...propsBase,
    feeHash: {}
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test.skip('props.onCarriage is true', () => {
  const props = {
    ...propsBase,
    onCarriage: true
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test.skip('props.preCarriage is true', () => {
  const props = {
    ...propsBase,
    preCarriage: true
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test.skip('props.destinationFees is true', () => {
  const props = {
    ...propsBase,
    destinationFees: true
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test.skip('props.firstStep is true', () => {
  const props = {
    ...propsBase,
    firstStep: true
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})
