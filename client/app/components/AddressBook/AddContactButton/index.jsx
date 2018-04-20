import React from 'react'
import { v4 } from 'node-uuid'
import styles from './AddressBookAddContactButton.scss'

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
