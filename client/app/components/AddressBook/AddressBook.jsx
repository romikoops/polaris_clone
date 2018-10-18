import React from 'react'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import styles from './AddressBook.scss'
import ContactCard from '../ContactCard'
import AddressBookAddContactButton from './AddContactButton'

export default function AddressBook ({
  theme, contacts, setContact, addContact
}) {
  const contactCards =
    contacts &&
    contacts.map(contact => (
      <div key={v4()} className="flex-50 layout-row layout-align-start-stretch ccb_contact" style={{ padding: '15px' }}>
        <ContactCard
          contactData={contact}
          theme={theme}
          select={setContact}
        />
      </div>
    ))
  contactCards.unshift((
    <div className="flex-50 layout-row layout-align-start-stretch" style={{ padding: '15px' }}>
      <AddressBookAddContactButton addContact={addContact} />
    </div>
  ))

  return (
    <div
      className={`
        ${styles.contact_scroll} flex-100 layout-row layout-wrap layout-align-start ccb_contacts
      `}
    >
      {contactCards}
    </div>
  )
}

AddressBook.propTypes = {
  contacts: PropTypes.arrayOf(PropTypes.any),
  theme: PropTypes.theme,
  setContact: PropTypes.func.isRequired,
  addContact: PropTypes.func.isRequired
}

AddressBook.defaultProps = {
  contacts: [],
  theme: null
}
