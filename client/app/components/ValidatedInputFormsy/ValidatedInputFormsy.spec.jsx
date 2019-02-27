import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../mocks/index'

import ValidatedInputFormsy from './ValidatedInputFormsy'

// Without the mock, we get the following error
// TypeError: Cannot read property 'attachToForm' of undefined
// ============================================
jest.mock('formsy-react', () => ({
  withFormsy: x => x
}))

const propsBase = {
  isValidValue: identity,
  name: 'NAME',
  className: 'CLASSNAME',
  disabled: false,
  type: 'TYPE',
  placeholder: 'PLACEHOLDER',
  inputRef: <div />,
  isValid: identity,
  getErrorMessage: identity,
  setValue: identity,
  onChange: identity,
  getValue: identity,
  setFirstRenderInputs: identity,
  firstRenderInputs: false,
  nextStageAttempt: false,
  onKeyDown: identity,
  min: 'MIN',
  errorStyles: {}
}

test('shallow render', () => {
  expect(shallow(<ValidatedInputFormsy {...propsBase} />)).toMatchSnapshot()
})

test('props.nextStageAttempt is true', () => {
  const props = {
    ...propsBase,
    nextStageAttempt: true
  }
  expect(shallow(<ValidatedInputFormsy {...props} />)).toMatchSnapshot()
})
