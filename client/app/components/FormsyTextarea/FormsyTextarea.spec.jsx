import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../mocks'

jest.mock('formsy-react', () => ({
  withFormsy: x => x
}))
// eslint-disable-next-line
import FormsyTextarea from './FormsyTextarea'

const propsBase = {
  name: 'FOO_NAME',
  className: 'FOO_CLASS_NAME',
  disabled: false,
  type: 'FOO_TYPE',
  isValid: identity,
  getErrorMessage: identity,
  setValue: identity,
  getValue: identity,
  submitAttempted: false,
  onFocus: identity,
  rows: 3,
  onBlur: identity,
  placeholder: 'FOO_PLACEHOLDER',
  id: 'FOO_ID',
  onChange: identity,
  errorMessageStyles: {},
  wrapperClassName: 'FOO_WRAPPER_CLASS_NAME'
}

test('shallow render', () => {
  expect(shallow(<FormsyTextarea {...propsBase} />)).toMatchSnapshot()
})

