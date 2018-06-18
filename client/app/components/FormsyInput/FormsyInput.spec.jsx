import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../mocks'

jest.mock('formsy-react', () => ({
  withFormsy: x => x
}))
// eslint-disable-next-line
import FormsyInput from './FormsyInput'

const propsBase = {
  name: 'FOO_NAME',
  className: 'FOO_CLASSNAME',
  disabled: false,
  type: 'FOO_TYPE',
  isValid: identity,
  getErrorMessage: identity,
  setValue: identity,
  getValue: identity,
  submitAttempted: false,
  onFocus: identity,
  onBlur: identity,
  placeholder: 'FOO_PLACEHOLDER',
  id: 'FOO_ID',
  onChange: identity,
  errorMessageStyles: {},
  wrapperClassName: 'FOO_WRAPPER'
}

test('shallow render', () => {
  expect(shallow(<FormsyInput {...propsBase} />)).toMatchSnapshot()
})
