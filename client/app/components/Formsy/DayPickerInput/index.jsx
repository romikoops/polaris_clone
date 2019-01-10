import React, { Component } from 'react'
import { withFormsy } from 'formsy-react'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import moment from 'moment'
import styles from './index.scss'
import errorStyles from '../../../styles/errors.scss'

class FormsyDayPickerInput extends Component {
  constructor (props) {
    super(props)
    this.changeValue = this.changeValue.bind(this)
  }

  changeValue (selectedDay, modifiers, dayPickerInput) {
    const { onDayChange, setValue, format } = this.props

    if (typeof onDayChange === 'function') {
      onDayChange(selectedDay, modifiers, dayPickerInput)
    }

    // setValue() will set the value of the component, which in
    // turn will validate it and the rest of the form
    // Important: Don't skip this step. This pattern is required
    // for Formsy to work.
    setValue(moment(selectedDay).format(format))
  }

  render () {
    const {
      getErrorMessage, isValid, getValue, wrapperClassName,
      name, placeholder, id, isPristine, validatePristine,
      errorMessageStyles, format, inputProps, dayPickerProps
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

    const value = getValue()

    const fullInputProps = {
      ...inputProps,
      style: inputStyles,
      value,
      name,
      placeholder,
      id
    }

    return (
      <div className={`${wrapperClassName} ${styles.wrapper_input}`}>
        <DayPickerInput
          onDayChange={this.changeValue}
          format={format}
          value={value}
          inputProps={fullInputProps}
          dayPickerProps={dayPickerProps}
        />
        <span className={errorStyles.error_message} style={errorMessageStyles}>
          {errorHidden ? '' : errorMessage}
        </span>
      </div>
    )
  }
}

FormsyDayPickerInput.defaultProps = {
  disabled: false,
  placeholder: 'DD/MM/YYYY',
  id: null,
  errorMessageStyles: {},
  onChange: null,
  wrapperClassName: '',
  format: 'DD/MM/YYYY',
  inputProps: {},
  dayPickerProps: null,
  validatePristine: false
}

export default withFormsy(FormsyDayPickerInput)
