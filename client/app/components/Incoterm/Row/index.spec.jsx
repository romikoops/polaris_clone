import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change, feeHash, theme, tenant, shipment
} from '../../../mocks/index'

import IncotermRow from '.'

const propsBase = {
  theme,
  feeHash,
  onCarriage: false,
  preCarriage: false,
  originFees: false,
  destinationFees: false,
  tenant,
  shipment,
  mot: 'ocean',
  firstStep: false
}

test('shallow render', () => {
  expect(shallow(<IncotermRow {...propsBase} />)).toMatchSnapshot()
})

test('originFees && destinationFees are true', () => {
  const props = {
    ...propsBase,
    originFees: true,
    destinationFees: true
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test('feeHash is empty object', () => {
  const props = {
    ...propsBase,
    feeHash: {}
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test('feeHash.trucking_on is empty object', () => {
  const props = change(
    propsBase,
    'feeHash.trucking_on',
    {}
  )
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test('feeHash.trucking_pre is empty object', () => {
  const props = change(
    propsBase,
    'feeHash.trucking_pre',
    {}
  )
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test('feeHash.import is empty object', () => {
  const props = change(
    propsBase,
    'feeHash.import',
    {}
  )
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test('feeHash.export is empty object', () => {
  const props = change(
    propsBase,
    'feeHash.export',
    {}
  )
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test('onCarriage is true', () => {
  const props = {
    ...propsBase,
    onCarriage: true
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test('preCarriage is true', () => {
  const props = {
    ...propsBase,
    preCarriage: true
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test('destinationFees is true', () => {
  const props = {
    ...propsBase,
    destinationFees: true
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test('firstStep is true', () => {
  const props = {
    ...propsBase,
    firstStep: true
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<IncotermRow {...props} />)).toMatchSnapshot()
})
