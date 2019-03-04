import React, { Component } from 'react'
import { withFormsy } from 'formsy-react'
import Select from 'react-select'
import styled from 'styled-components'
import styles from './index.scss'
import errorStyles from '../../../styles/errors.scss'

const reactSelectErrorStyles = `
  .Select-control {
    background-color: #FAD1CA;
  }
  .Select-value {
    background-color: #FAD1CA;
    border: 1px solid #f2f2f2;
  }
  .Select-placeholder {
    color: rgb(211, 104, 80);
  }
`

const StyledSelect = styled(Select)`
  ${props => props.customStyles}
  ${props => props.applyErrorStyles && reactSelectErrorStyles}
`

class FormsySelect extends Component {
  constructor (props) {
    super(props)
    this.changeValue = this.changeValue.bind(this)
    this.errorIsHidden = this.errorIsHidden.bind(this)
  }

  changeValue (value, selectedOptions) {
    const { onChange, setValue, multiple } = this.props

    if (typeof onChange === 'function') {
      onChange(value, selectedOptions)
    }
    // setValue() will set the value of the component, which in
    // turn will validate it and the rest of the form
    // Important: Don't skip this step. This pattern is required
    // for Formsy to work.
    if (multiple) {
      setValue(selectedOptions.map(option => option.value))
    } else {
      setValue(value)
    }
  }

  errorIsHidden () {
    const { validatePristine, isPristine } = this.props

    return !validatePristine && isPristine()
  }

  render () {
    const {
      getErrorMessage, isValid, getValue, wrapperClassName,
      name, className, placeholder, id, options, customStyles,
      errorMessageStyles
    } = this.props

    // An error message is returned only if the component is invalid
    const errorMessage = getErrorMessage()

    // errors are hidden for pristine inputs by default
    const errorHidden = this.errorIsHidden()

    const value = getValue()

    return (
      <div className={`${wrapperClassName} ${styles.wrapper_input}`}>
        <StyledSelect
          id={id}
          name={name}
          className={className}
          value={value}
          placeholder={placeholder}
          options={options}
          onChange={this.changeValue}
          customStyles={customStyles}
          applyErrorStyles={!errorHidden && !isValid()}
        />

        <span className={errorStyles.error_message} style={errorMessageStyles}>
          {errorHidden ? '' : errorMessage}
        </span>
      </div>
    )
  }
}

FormsySelect.defaultProps = {
  disabled: false,
  placeholder: null,
  id: null,
  errorMessageStyles: {},
  onChange: null,
  wrapperClassName: '',
  className: '',
  validatePristine: false,
  customStyles: `
    .Select-control {
      background-color: #F9F9F9;
      box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
      border: 1px solid #f2f2f2 !important;
    }
    .Select-menu-outer {
      box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
      border: 1px solid #f2f2f2;
    }
    .Select-value {
      background-color: #F9F9F9;
      border: 1px solid #f2f2f2;
    }
    .Select-option {
      background-color: #f9f9f9;
    }
  `
}

export default withFormsy(FormsySelect)
