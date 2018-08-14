import React from 'react'
import { v4 } from 'uuid'
import styles from './AddressBookAddContactButton.scss'
import PropTypes from '../../../prop-types'

export default function AddressBookAddContactButton ({
  addContact
}) {
  return (
    <div
      key={v4()}
      className={`flex-100 layout-row layout-align-center-center ${styles.add_contact_btn}`}
      onClick={addContact}
    >
      <h3>
        + NEW CONTACT
      </h3>
    </div>
  )
}

AddressBookAddContactButton.propTypes = {
  addContact: PropTypes.func.isRequired
}
