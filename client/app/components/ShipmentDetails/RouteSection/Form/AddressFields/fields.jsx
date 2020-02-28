import React, { useState } from 'react'
import { withNamespaces } from 'react-i18next'

import Field from './field'
import styles from './index.scss'

function Fields (props) {
  const {
    t,
    value,
    hide,
    onChange,
    onClear,
    onFocus,
    requiresFullAddress,
    disabled
  } = props

  if (hide) return null

  const [cleaning, setCleaning] = useState(false)

  const onBlurHandler = (event) => {
    setCleaning(false)
    onChange(event.target.name, event.target.value)
  }

  const onClearHandler = (event) => {
    setCleaning(true)
    onClear(event)
  }

  const isBlankValidation = (_, fieldValue) => {
    if (cleaning || disabled) {
      return true
    }

    return !!fieldValue
  }

  const requiresFullAddressValidation = (_, fieldValue) => {
    if (cleaning || disabled) {
      return true
    }

    return (requiresFullAddress && !!fieldValue) || (!requiresFullAddress)
  }

  return (
    <div className={styles.fieldsContainer}>
      <Field
        name="street"
        label={t('street')}
        value={value.street}
        className={styles.fieldStreet}
        onBlur={onBlurHandler}
        onFocus={onFocus}
        disabled={disabled}
        validations={{ requiresFullAddress: requiresFullAddressValidation }}
      />

      <Field
        name="number"
        label={t('number')}
        value={value.number}
        className={styles.fieldNumber}
        onBlur={onBlurHandler}
        onFocus={onFocus}
        disabled={disabled}
        validations={{ requiresFullAddress: requiresFullAddressValidation }}
      />

      <Field
        name="zipCode"
        label={t('postalCode')}
        value={value.zipCode}
        className={styles.fieldPostalcode}
        onBlur={onBlurHandler}
        onFocus={onFocus}
        disabled={disabled}
        validations={{ isBlank: isBlankValidation }}
      />

      <Field
        name="city"
        label={t('city')}
        value={value.city}
        className={styles.fieldCity}
        onBlur={onBlurHandler}
        onFocus={onFocus}
        disabled={disabled}
        validations={{ isBlank: isBlankValidation }}
      />

      <Field
        name="country"
        label={t('country')}
        value={value.country}
        className={styles.fieldCountry}
        onBlur={onBlurHandler}
        onFocus={onFocus}
        disabled={disabled}
        validations={{ isBlank: isBlankValidation }}
      />

      <a className={styles.clearButton} onClick={onClearHandler}>
        <i className="fa fa-times" />
      </a>
    </div>
  )
}

export default withNamespaces(['address'])(Fields)
