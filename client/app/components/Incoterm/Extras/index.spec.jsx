import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, tenant, shipment } from '../../../mocks'

jest.mock('../../../helpers', () => ({
  gradientTextGenerator: (x, y) =>
    ({ background: `-webkit-linear-gradient(left, ${x},${y})` })
}))
// eslint-disable-next-line
import IncotermExtras from './'

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
    customs: { val: 12, currency: 'EUR' },
    insurance: { val: 20, currency: 'EUR' }
  },
  tenant: editedTenant,
  shipment
}

test.skip('shallow render', () => {
  expect(shallow(<IncotermExtras {...propsBase} />)).toMatchSnapshot()
})

test.skip('props.feeHash is empty object', () => {
  const props = {
    ...propsBase,
    feeHash: {}
  }
  expect(shallow(<IncotermExtras {...props} />)).toMatchSnapshot()
})
