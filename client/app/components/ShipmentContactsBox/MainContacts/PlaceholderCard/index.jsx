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
      style={requiredSpanStyles}
    >
      * Required
    </span>
  )
  return (
    <div
      className={
        `layout-row layout-wrap ${styles.placeholder_card} ` +
        `${showError ? styles.with_errors : ''}`
      }
      onClick={() => showAddressBook(contactType)}
    >
      <div className="flex-100 layout-row layout-align-center-center">
        <h3>
          Choose a  <br />
          <span className={styles.contact_type}> { capitalize(nameToDisplay(contactType)) } </span>
        </h3>
      </div>
      { showError && requiredSpan }
    </div>
  )
}
