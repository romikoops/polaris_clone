import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, shipment } from '../../../mocks'

import IncotermBox from '.'

const propsBase = {
  theme,
  onCarriage: false,
  preCarriage: false,
  shipment,
  tenantScope: { incoterm_info_level: 'simple' },
  incoterm: 'INCOTERM',
  setIncoterm: identity,
  errorStyles: {},
  showIncotermError: false,
  nextStageAttempt: false,
  value: false,
  direction: 'export'
}

test('incoterm_info_level is simple', () => {
  expect(shallow(<IncotermBox {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<IncotermBox {...props} />)).toMatchSnapshot()
})

test('incoterm_info_level render is text', () => {
  const props = {
    ...propsBase,
    tenantScope: {
      incoterm_info_level: 'text'
    }
  }
  expect(shallow(<IncotermBox {...props} />)).toMatchSnapshot()
})

test('incoterm_info_level render is full', () => {
  const props = {
    ...propsBase,
    tenantScope: {
      incoterm_info_level: 'full'
    }
  }
  expect(shallow(<IncotermBox {...props} />)).toMatchSnapshot()
})

test('tenantScope is empty object', () => {
  const props = {
    ...propsBase,
    tenantScope: {}
  }
  expect(shallow(<IncotermBox {...props} />)).toMatchSnapshot()
})

test('preCarriage is true', () => {
  const props = {
    ...propsBase,
    preCarriage: true
  }
  expect(shallow(<IncotermBox {...props} />)).toMatchSnapshot()
})

test('onCarriage is true', () => {
  const props = {
    ...propsBase,
    onCarriage: true
  }
  expect(shallow(<IncotermBox {...props} />)).toMatchSnapshot()
})

test('preCarriage&&onCarriage is true', () => {
  const props = {
    ...propsBase,
    onCarriage: true,
    preCarriage: true
  }
  expect(shallow(<IncotermBox {...props} />)).toMatchSnapshot()
})
