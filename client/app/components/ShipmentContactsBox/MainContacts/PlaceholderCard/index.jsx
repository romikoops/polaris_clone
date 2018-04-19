import React from 'react'
import styles from '../../ShipmentContactsBox.scss'
import errors from '../../../../styles/errors.scss'
import { capitalize, nameToDisplay } from '../../../../helpers'
import { RoundButton } from '../../../RoundButton/RoundButton'

export default function ShipmentContactsBoxMainContactsPlaceholderCard ({
  contactType, theme, showAddressBook
}) {
  const showError = false // TBD - finishBookingAttempted
  const requiredSpanStyles = {
    left: '10px', top: '10px', bottom: 'unset', fontSize: '14px'
  }
  const requiredSpan = (
    <span
      className={errors.error_message}
      style={Object.assign(requiredSpanStyles, showError ? {} : { color: 'inherit' })}
    >
      * Required
    </span>
  )
  return (
    <div className={
      `layout-row layout-wrap ${styles.placeholder_card} ` +
      `${showError ? styles.with_errors : ''}`
    }
    >
      <div className="flex-100 layout-row layout-align-center-center">
        <h3>
          Choose a  <br />
          <span className={styles.contact_type}> { capitalize(nameToDisplay(contactType)) } </span>
        </h3>
      </div>
      <div className="flex-100 layout-row layout-align-center-start">
        <RoundButton
          theme={theme}
          text="BROWSE CONTACTS"
          size="medium"
          handleNext={() => showAddressBook(contactType)}
          active
        />
      </div>
      <div className="flex-100 layout-row layout-align-center-start">
        <a onClick={null} className={styles.link}>+ add contact</a>
      </div>
      { requiredSpan }
    </div>
  )
}
