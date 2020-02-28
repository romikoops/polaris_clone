import React from 'react'
import FormsyInput from '../../../../Formsy/Input'
import styles from './index.scss'

const Field = (props) => {
  const {
    className,
    label,
    name,
    onBlur,
    onFocus,
    onChange,
    validations,
    value,
    disabled
  } = props

  return (
    <div className={`${styles.field} ${className}`}>
      <label htmlFor={name}>{label}</label>
      <FormsyInput
        name={name}
        placeholder={label}
        value={value}
        onBlur={onBlur}
        onChange={onChange}
        onFocus={onFocus}
        validations={validations}
        disabled={disabled}
      />
    </div>
  )
}

Field.defaultProps = {
  className: '',
  label: '',
  name: '',
  onBlur: () => {},
  validations: {},
  value: '',
  disabled: false
}

export default Field
