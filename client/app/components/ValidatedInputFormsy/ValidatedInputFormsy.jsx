import React, { Component } from 'react'
import { withFormsy } from 'formsy-react'
import PropTypes from 'prop-types'
import styles from './ValidatedInputFormsy.scss'
import errorStyles from '../../styles/errors.scss'

class ValidatedInputFormsy extends Component {
  constructor (props) {
    super(props)
    this.changeValue = this.changeValue.bind(this)
    this.state = { firstRender: true }
    this.errorsHaveUpdated = false
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.firstRenderInputs || nextProps.nextStageAttempt) {
      this.setState({ firstRender: nextProps.firstRenderInputs })
    }
  }

  componentDidUpdate () {
    if (this.errorsHaveUpdated) return // Break the loop if erros have updated
    const event = { target: { name: this.props.name, value: this.props.getValue() } }

    const validationPassed = this.props.isValidValue(event.target.value)

    // break out of function if validation did not pass. This assumes default state in
    // parent has errors set to true
    if (!validationPassed) return

    // Trigger onChange event, and flag errorsHaveUpdated as true,
    // in order to avoid an infinite loop.
    this.props.onChange(event, !validationPassed)
    this.errorsHaveUpdated = true
  }

  changeValue (event) {
    this.props.onChange(event, !this.props.isValidValue(event.target.value))
    if (this.props.setFirstRenderInputs) this.props.setFirstRenderInputs(false)
    this.setState({ firstRender: false })
    // setValue() will set the value of the component, which in
    // turn will validate it and the rest of the form
    // Important: Don't skip this step. This pattern is required
    // for Formsy to work.
    this.props.setValue(event.currentTarget.value)
  }

  render () {
    // An error message is returned only if the component is invalid
    const errorMessage = this.props.getErrorMessage()
    const inputStyles = {
      width: '100%',
      height: '100%',
      boxSizing: 'border-box'
    }
    const ErrorHidden = this.state.firstRender && !this.props.nextStageAttempt
    if (!ErrorHidden && !this.props.isValid()) {
      inputStyles.background = 'rgba(232, 114, 88, 0.3)'
      inputStyles.borderColor = 'rgba(232, 114, 88, 0.01)'
      inputStyles.color = 'rgba(211, 104, 80, 1)'
    }
    // const value = (this.props.getValue() !== undefined &&
    // !Number.isNaN(this.props.getValue())) ? this.props.getValue() : ''
    const value = this.props.getValue()

    return (
      <div className={styles.wrapper_input}>
        <input
          ref={this.props.inputRef}
          style={inputStyles}
          onChange={this.changeValue}
          placeholder={this.props.placeholder}
          type={this.props.type}
          value={value}
          name={this.props.name}
          disabled={this.props.disabled}
          className={this.props.className}
          onKeyDown={this.props.onKeyDown}
          min={this.props.min}
          data-hj-whitelist
        />
        <span
          className={errorStyles.error_message}
          style={this.props.errorStyles}
        >
          {ErrorHidden ? '' : errorMessage}
        </span>
      </div>
    )
  }
}

ValidatedInputFormsy.propTypes = {
  isValidValue: PropTypes.func.isRequired,
  name: PropTypes.string.isRequired,
  className: PropTypes.string,
  disabled: PropTypes.bool,
  type: PropTypes.string.isRequired,
  placeholder: PropTypes.string,
  inputRef: PropTypes.element,
  isValid: PropTypes.func.isRequired,
  getErrorMessage: PropTypes.func.isRequired,
  setValue: PropTypes.func.isRequired,
  onChange: PropTypes.func.isRequired,
  getValue: PropTypes.func.isRequired,
  setFirstRenderInputs: PropTypes.func,
  firstRenderInputs: PropTypes.bool,
  nextStageAttempt: PropTypes.bool,
  onKeyDown: PropTypes.func,
  min: PropTypes.string,
  errorStyles: PropTypes.objectOf(PropTypes.string)
}

ValidatedInputFormsy.defaultProps = {
  disabled: false,
  placeholder: '',
  setFirstRenderInputs: null,
  firstRenderInputs: false,
  nextStageAttempt: false,
  onKeyDown: null,
  min: '',
  errorStyles: {},
  inputRef: null,
  className: ''
}

export default withFormsy(ValidatedInputFormsy)
