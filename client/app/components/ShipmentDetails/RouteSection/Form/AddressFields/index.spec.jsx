import * as React from 'react'
import { shallow } from 'enzyme'
import AddressFields from '.'
import {
  scope,
  theme,
  identity
} from '../../../mocks'

const propsBase = {
  map: {},
  gMaps: {},
  theme,
  scope,
  target: 'TARGET',
  carriage: 'pre',
  onAutocompleteTrigger: identity,
  onInputBlur: identity,
  formData: {},
  countries: []
}

test('with empty props', () => {
  expect(() => shallow(<AddressFields />)).toThrow()
})

test('happy path', () => {
  expect(shallow(<AddressFields {...propsBase} />)).toMatchSnapshot()
})
