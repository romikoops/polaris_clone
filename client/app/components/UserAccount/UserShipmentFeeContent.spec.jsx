import * as React from 'react'
import { shallow } from 'enzyme'

import UserShipmentFeeContent from './UserShipmentFeeContent'

test('when feetype passed total', () => {
  const feeHashType = {
    total: {
      value: 500,
      currency: 'EUR'
    }
  }
  const feeContent = shallow(<UserShipmentFeeContent feeHashType={feeHashType} />)
  expect(feeContent).toMatchSnapshot()
  expect(feeContent.contains('500.00')).toBe(true)
  expect(feeContent.contains('EUR')).toBe(true)
})

test('when feetype not passed total', () => {
  const feeHashType = {}

  const feeContent = shallow(<UserShipmentFeeContent feeHashType={feeHashType} />)
  expect(feeContent).toMatchSnapshot()
  expect(feeContent.contains('500')).toBe(false)
  expect(feeContent.contains('EUR')).toBe(false)
})

test('when feetype passed edited total', () => {
  const feeHashType = {
    edited_total: {
      value: 600,
      currency: 'USD'
    }
  }

  const feeContent = shallow(<UserShipmentFeeContent feeHashType={feeHashType} />)
  expect(feeContent).toMatchSnapshot()
  expect(feeContent.contains('600.00')).toBe(true)
  expect(feeContent.contains('USD')).toBe(true)
})
