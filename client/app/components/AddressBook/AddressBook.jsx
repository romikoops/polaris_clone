import React, { PureComponent } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import styles from './AddressBook.scss'
import { ContactCard } from '../ContactCard/ContactCard'

export class AddressBook extends PureComponent {
  render () {
    const { theme, contacts, autofillContact } = this.props

    const contactCards =
      contacts &&
      contacts.map(contact => (
        <ContactCard
          contactData={contact}
          theme={theme}
          select={autofillContact}
          key={v4()}
          popOutHover
        />
      ))

    return (
      <div
        className={`
                ${styles.contact_scroll} flex-100 layout-row layout-wrap layout-align-center-start
            `}
      >
        {contactCards}
      </div>
    )
  }
}

AddressBook.propTypes = {
  contacts: PropTypes.arrayOf(PropTypes.contact),
  theme: PropTypes.theme,
}

AddressBook.defaultProps = {
  contacts: [],
  theme: null
}

export default AddressBook
