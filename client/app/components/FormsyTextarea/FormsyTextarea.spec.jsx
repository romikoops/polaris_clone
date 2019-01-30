import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../mocks'

import FormsyTextarea from './FormsyTextarea'

jest.mock('formsy-react', () => ({
  withFormsy: x => x
}))

const propsBase = {
  name: 'NAME',
  className: 'CLASS_NAME',
  disabled: false,
  type: 'TYPE',
  isValid: identity,
  getErrorMessage: identity,
  setValue: identity,
  getValue: identity,
  submitAttempted: false,
  onFocus: identity,
  rows: 3,
  onBlur: identity,
  placeholder: 'PLACEHOLDER',
  id: 'ID',
  onChange: identity,
  errorMessageStyles: {},
  wrapperClassName: 'WRAPPER_CLASSNAME'
}

test('shallow render', () => {
  expect(shallow(<FormsyTextarea {...propsBase} />)).toMatchSnapshot()
})

test('submitAttempted is true', () => {
  const props = {
    ...propsBase,
    submitAttempted: true
  }
  expect(shallow(<FormsyTextarea {...props} />)).toMatchSnapshot()
})

test('rawValue != null', () => {
  const props = {
    ...propsBase,
    getValue: () => 'VALUE'
  }
  expect(shallow(<FormsyTextarea {...props} />)).toMatchSnapshot()
})
