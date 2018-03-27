import React from 'react'
import PropTypes from '../../../prop-types'
import FormsyInput from '../../../components/FormsyInput/FormsyInput'
import { humanizeSnakeCase } from '../../../helpers'
import styles from '../RegistrationPage.scss'

function mergeMinLengthValidations (minLength, validations, validationErrors) {
  const returnObj = {}
  returnObj.validations = Object.assign(minLength ? { minLength } : {}, validations || {})

  const minLengthErrors = {
    isDefaultRequiredValue: `Min. ${minLength} characters`,
    minLength: `Min. ${minLength} characters`
  }
  returnObj.validationErrors = Object.assign(
    minLength ? minLengthErrors : {},
    validationErrors || {}
  )
  return returnObj
}

export default function RegistrationFormGroup (props) {
  const {
    field, flex, offset, minLength, type, required, theme, handleFocus, focus, submitAttempted
  } = props
  const focusStyles = {
    borderColor: theme && theme.colors ? theme.colors.primary : 'black',
    borderWidth: '1.5px',
    borderRadius: '2px',
    margin: '-1px 0 29px 0'
  }

  let { validations, validationErrors } = props
  if (minLength) {
    ({ validations, validationErrors } =
      mergeMinLengthValidations(minLength, validations, validationErrors))
  }

  return (
    <div className={`flex-${flex || '100'} offset-${offset || 0}`}>
      <label htmlFor={field}>{humanizeSnakeCase(field)}</label>
      <FormsyInput
        type={type || 'text'}
        className={styles.form_control}
        onFocus={handleFocus}
        onBlur={handleFocus}
        name={field}
        id={field}
        submitAttempted={submitAttempted}
        validations={validations}
        validationErrors={validationErrors}
        errorMessageStyles={{
          fontSize: '12px',
          bottom: '-19px'
        }}
        required={required}
      />
      <hr style={focus[field] ? focusStyles : {}} />
    </div>
  )
}

RegistrationFormGroup.propTypes = {
  field: PropTypes.string.isRequired,
  flex: PropTypes.string,
  offset: PropTypes.string,
  minLength: PropTypes.string,
  type: PropTypes.string,
  required: PropTypes.bool,
  theme: PropTypes.theme,
  handleFocus: PropTypes.func.isRequired,
  focus: PropTypes.objectOf(PropTypes.string).isRequired,
  submitAttempted: PropTypes.bool.isRequired,
  validations: PropTypes.objectOf(PropTypes.string).isRequired,
  validationErrors: PropTypes.objectOf(PropTypes.string).isRequired
}

RegistrationFormGroup.defaultProps = {
  flex: '',
  offset: '',
  minLength: '',
  type: '',
  required: true,
  theme: null
}
