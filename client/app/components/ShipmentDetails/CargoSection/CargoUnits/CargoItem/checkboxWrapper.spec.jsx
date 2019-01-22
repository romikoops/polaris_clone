import * as React from 'react'
import { shallow } from 'enzyme'
import CheckboxWrapper from './checkboxWrapper'
import { cargoItem, theme } from '../../../mocks'

test('with empty props', () => {
  expect(() => shallow(<CheckboxWrapper />)).toThrow()
})

test('happy path', () => {
  const props = {
    cargoItem,
    disabled: false,
    i: 0,
    labelText: 'LABEL_TEXT',
    onChange: null,
    prop: 'stackable',
    theme
  }
  expect(shallow(<CheckboxWrapper {...props} />)).toMatchSnapshot()
})
