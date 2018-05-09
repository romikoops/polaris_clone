import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../mocks'

jest.mock('formsy-react', () => ({
  withFormsy: x => x
}))
// eslint-disable-next-line import/first
import ValidatedInputFormsy from './ValidatedInputFormsy'

const propsBase = {
  isValidValue: identity,
  name: 'FOO_NAME',
  className: 'FOO_CLASSNAME',
  disabled: false,
  type: 'FOO_TYPE',
  placeholder: 'FOO_PLACEHOLDER',
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
  min: 'FOO_MIN',
  errorStyles: {}
}

/**
 * props.shipment should be array of `shipment` object but
 * shipments[target].map leads to other conclusion
 */
test('shallow render', () => {
  expect(shallow(<ValidatedInputFormsy {...propsBase} />)).toMatchSnapshot()
})
