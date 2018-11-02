import React from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import styles from './AddressBookAddContactButton.scss'
import PropTypes from '../../../prop-types'

export function AddressBookAddContactButton ({
  addContact,
  t
}) {
  return (
    <div
      key={v4()}
      className={`flex-100 layout-row layout-align-center-center ccb_new_contact ${styles.add_contact_btn}`}
      onClick={addContact}
    >
      <h3>{`+ ${t('common:newContact')}`}</h3>
    </div>
  )
}

AddressBookAddContactButton.propTypes = {
  addContact: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired
}

export default withNamespaces('common')(AddressBookAddContactButton)
