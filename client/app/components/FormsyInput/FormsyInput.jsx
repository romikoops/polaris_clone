import React, { Component } from 'react'
import { withFormsy } from 'formsy-react'
import PropTypes from 'prop-types'
import styles from './FormsyInput.scss'
import errorStyles from '../../styles/errors.scss'

class FormsyInput extends Component {
  constructor (props) {
    super(props)
    this.changeValue = this.changeValue.bind(this)
  }

  changeValue (event) {
    if (typeof this.props.onChange === 'function') {
      this.props.onChange(event)
    }
    // setValue() will set the value of the component, which in
    // turn will validate it and the rest of the form
    // Important: Don't skip this step. This pattern is required
    // for Formsy to work.
    this.props.setValue(event.currentTarget.value)
  }
  render () {
    // An error message is returned only if the component is invalid
    const errorMessage = this.props.getErrorMessage()
    const inputStyles = {}
    const errorHidden = !this.props.submitAttempted
    if (!errorHidden && !this.props.isValid()) {
      inputStyles.background = 'rgba(232, 114, 88, 0.3)'
      inputStyles.borderColor = 'rgba(232, 114, 88, 0.01)'
      inputStyles.color = 'rgba(211, 104, 80, 1)'
    }
    const rawValue = this.props.getValue()
    const value = rawValue == null ? '' : this.props.getValue().toString()

    return (
      <div className={`${this.props.wrapperClassName} ${styles.wrapper_input}`}>
        <input
          style={inputStyles}
          onChange={this.changeValue}
          type={this.props.type}
          value={value}
          name={this.props.name}
          disabled={this.props.disabled}
          className={this.props.className}
          onFocus={this.props.onFocus}
          onBlur={this.props.onBlur}
          placeholder={this.props.placeholder}
          id={this.props.id}
        />
        <span className={errorStyles.error_message} style={this.props.errorMessageStyles}>
          {errorHidden ? '' : errorMessage}
        </span>
      </div>
    )
  }
}

FormsyInput.propTypes = {
  name: PropTypes.string.isRequired,
  className: PropTypes.string,
  disabled: PropTypes.bool,
  type: PropTypes.string.isRequired,
  isValid: PropTypes.func.isRequired,
  getErrorMessage: PropTypes.func.isRequired,
  setValue: PropTypes.func.isRequired,
  getValue: PropTypes.func.isRequired,
  submitAttempted: PropTypes.bool,
  onFocus: PropTypes.func,
  onBlur: PropTypes.func,
  placeholder: PropTypes.string,
  id: PropTypes.string,
  onChange: PropTypes.func,
  errorMessageStyles: PropTypes.objectOf(PropTypes.string),
  wrapperClassName: PropTypes.string
}

FormsyInput.defaultProps = {
  disabled: false,
  submitAttempted: false,
  onFocus: null,
  placeholder: null,
  id: null,
  onBlur: null,
  errorMessageStyles: {},
  onChange: null,
  wrapperClassName: '',
  className: ''
}

export default withFormsy(FormsyInput)
