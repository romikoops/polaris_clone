import React from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import styles from './AddressBook.scss'
import ContactCard from '../ContactCard'
import AddressBookAddContactButton from './AddContactButton'

export default function AddressBook ({
  theme, contacts, setContact, title
}) {
  const contactCards =
    contacts &&
    contacts.map(contact => (
      <div className="flex-50" style={{ padding: '15px' }}>
        <ContactCard
          contactData={contact}
          theme={theme}
          select={setContact}
          key={v4()}
          popOutHover
        />
      </div>
    ))

  contactCards.unshift((
    <div className="flex-50" style={{ padding: '15px' }}>
      <AddressBookAddContactButton />
    </div>
  ))

  return (
    <div className={styles.address_book}>
      <div className={`${styles.title_sec} layout-row layout-align-center`}>
        { title }
      </div>
      <div className={styles.wrapper_contact_cards}>
        <div
          className={`
            ${styles.contact_scroll} flex-100 layout-row layout-wrap layout-align-start
          `}
        >
          {contactCards}
        </div>
      </div>
    </div>
  )
}

AddressBook.propTypes = {
  contacts: PropTypes.arrayOf(PropTypes.contact),
  theme: PropTypes.theme,
  setContact: PropTypes.func.isRequired
}

AddressBook.defaultProps = {
  contacts: [],
  theme: null
}
