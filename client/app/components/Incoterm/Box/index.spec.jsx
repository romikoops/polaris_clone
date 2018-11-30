import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, shipment } from '../../../mocks'

jest.mock('../../../helpers', () => ({
  gradientTextGenerator: x => x
}))
// eslint-disable-next-line
import IncotermBox from './'

const propsBase = {
  theme,
  onCarriage: false,
  preCarriage: false,
  shipment,
  tenantScope: { incoterm_info_level: 'simple' },
  incoterm: 'FOO_INCOTERM',
  setIncoterm: identity,
  errorStyles: {},
  showIncotermError: false,
  nextStageAttempt: false,
  value: false,
  direction: 'FOO_DIRECTION'
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
