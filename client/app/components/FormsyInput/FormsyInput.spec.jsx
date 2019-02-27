import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../mocks/index'
import FormsyInput from './FormsyInput'

jest.mock('formsy-react', () => ({
  withFormsy: x => x
}))

const propsBase = {
  name: 'NAME',
  className: 'CLASSNAME',
  disabled: false,
  type: 'TYPE',
  isValid: identity,
  getErrorMessage: identity,
  setValue: identity,
  getValue: identity,
  submitAttempted: false,
  onFocus: identity,
  onBlur: identity,
  placeholder: 'PLACEHOLDER',
  id: 'ID',
  onChange: identity,
  errorMessageStyles: {},
  wrapperClassName: 'WRAPPER_CLASSNAME'
}

test('shallow render', () => {
  expect(shallow(<FormsyInput {...propsBase} />)).toMatchSnapshot()
})

test('!errorHidden && !props.isValid()', () => {
  const props = {
    ...propsBase,
    submitAttempted: true,
    isValid: () => false
  }
  expect(shallow(<FormsyInput {...props} />)).toMatchSnapshot()
})
