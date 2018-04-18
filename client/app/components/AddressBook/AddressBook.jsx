import React, { PureComponent } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import styles from './AddressBook.scss'
import { ContactCard } from '../ContactCard/ContactCard'

export class AddressBook extends PureComponent {
  render () {
    const { theme, contacts, setContact } = this.props

    const contactCards =
      contacts &&
      contacts.map(contact => (
        <ContactCard
          contactData={contact}
          theme={theme}
          select={setContact}
          key={v4()}
          popOutHover
        />
      ))

    return (
      <div style={{ height: '50vh', width: '70vw' }}>
        <div
          className={`
            ${styles.contact_scroll} flex-100 layout-row layout-wrap layout-align-center-start
          `}
        >
          {contactCards}
        </div>
      </div>
    )
  }
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

export default AddressBook
