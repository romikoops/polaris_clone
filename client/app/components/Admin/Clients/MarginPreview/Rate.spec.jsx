import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../../../mocks'

import AdminMarginPreviewRate from './Rate'


jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const propsBase = {
  t: identity,
  feeKey: 'FSC',
  type: 'trucking_pre',
  rate: { original: {}, margins: [], final: {}, flatMargins: [], rate_origin: {} },
  price: { name: "FSC" }
}

test('shallow render trucking aux fee', () => {
  expect(shallow(<AdminMarginPreviewRate {...propsBase} />)).toMatchSnapshot()
})

test('shallow render trucking main fee', () => {
  const truckingPropsBase = {
    ...propsBase,
    feeKey: 'trucking_lcl'
  }
  expect(shallow(<AdminMarginPreviewRate {...truckingPropsBase} />)).toMatchSnapshot()
})
