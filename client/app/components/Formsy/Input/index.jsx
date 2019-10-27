import React, { Component } from 'react'
import { withFormsy } from 'formsy-react'
import styles from './index.scss'
import errorStyles from '../../../styles/errors.scss'

class FormsyInput extends Component {
  constructor (props) {
    super(props)
    this.changeValue = this.changeValue.bind(this)
  }

  changeValue (event) {
    const { onChange, setValue } = this.props

    if (typeof onChange === 'function') {
      onChange(event)
    }
    // setValue() will set the value of the component, which in
    // turn will validate it and the rest of the form
    // Important: Don't skip this step. This pattern is required
    // for Formsy to work.
    setValue(event.currentTarget.value)
  }

  render () {
    const {
      getErrorMessage, isValid, getValue, wrapperClassName,
      type, name, disabled, className, onFocus, onBlur, placeholder, id,
      errorMessageStyles, validatePristine, isPristine, step
    } = this.props

    // An error message is returned only if the component is invalid
    const errorMessage = getErrorMessage()

    // errors are hidden for pristine inputs by default
    // (validatePristine defaults to false)
    const errorHidden = !validatePristine && isPristine()

    const inputStyles = {}
    if (!errorHidden && !isValid()) {
      inputStyles.background = 'rgba(232, 114, 88, 0.3)'
      inputStyles.borderColor = 'rgba(232, 114, 88, 0.01)'
      inputStyles.color = 'rgba(211, 104, 80, 1)'
    }
    const rawValue = getValue()
    const value = rawValue == null ? '' : getValue().toString()

    return (
      <div className={`${wrapperClassName} ${styles.wrapper_input}`}>
        <input
          style={inputStyles}
          onChange={this.changeValue}
          type={type}
          step={step}
          value={value}
          name={name}
          disabled={disabled}
          className={className}
          onFocus={onFocus}
          onBlur={onBlur}
          placeholder={placeholder}
          id={id}
        />
        <span className={errorStyles.error_message} style={errorMessageStyles}>
          {errorHidden ? '' : errorMessage}
        </span>
      </div>
    )
  }
}

FormsyInput.defaultProps = {
  disabled: false,
  onFocus: null,
  placeholder: null,
  id: null,
  onBlur: null,
  errorMessageStyles: {},
  onChange: null,
  wrapperClassName: '',
  className: '',
  validatePristine: false,
  step: '1'
}

export default withFormsy(FormsyInput)
