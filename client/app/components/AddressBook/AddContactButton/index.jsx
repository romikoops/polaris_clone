import React from 'react'
import { v4 } from 'uuid'
import styles from './AddressBookAddContactButton.scss'
import { translate } from 'react-i18next'
import PropTypes from '../../../prop-types'

export function AddressBookAddContactButton ({
  addContact,
  t
}) {
  return (
    <div
      key={v4()}
      className={`flex-100 layout-row layout-align-center-center ${styles.add_contact_btn}`}
      onClick={addContact}
    >
      <h3>
        + {t('common:newContact')}
      </h3>
    </div>
  )
}

AddressBookAddContactButton.propTypes = {
  addContact: PropTypes.func.isRequired
}

export default translate(['common'])(AddressBookAddContactButton)
