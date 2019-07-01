import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { bookingProcessActions } from '../../actions'
import styles from './AddressBook.scss'
import ContactCard from '../ContactCard'
import AddressBookAddContactButton from './AddContactButton'
import Pagination from '../../containers/Pagination'

class AddressBook extends Component {
  constructor (props) {
    super(props)
    this.state = {
    }

    this.addressBookContacts = this.addressBookContacts.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.availableContacts = this.availableContacts.bind(this)
  }

  handleChange (args) {
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.getContacts(args)
  }

  availableContacts (contactType) {
    const {
      setContacts, contacts
    } = this.props
    if (!contacts) return []

    return contacts.filter(contactData => (
      setContacts.indexOf(contactData) === -1
    ))
  }

  addressBookContacts (contacts) {
    const {
      theme, setContact, addContact
    } = this.props
    const availableContacts = this.availableContacts()
    const contactCards =
      availableContacts &&
      availableContacts.map(currentContact => (
        <div key={v4()} className="flex-50 layout-row layout-align-start-stretch ccb_contact" style={{ padding: '15px' }}>
          <ContactCard
            contactData={currentContact}
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
    if (contactCards.length < 4) {
      const missingNoCards = 4 - contactCards.length
      for (let index = 0; index < missingNoCards; index++) {
        contactCards.push(<div key={v4()} className="flex-50 layout-row layout-align-start-stretch ccb_contact" style={{ padding: '15px' }}>
          <ContactCard
            contactData={{}}
            theme={theme}
          />
        </div>)
      }
    }

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

  render () {
    const {
      contacts, t, numContactPages, per_page
    } = this.props

    return (
      <div>
        <div
          className={`
            ${styles.contact_scroll} flex-100 layout-row layout-wrap layout-align-start ccb_contacts
          `}
        >
          <Pagination
            items={contacts}
            remote
            searchable
            pageNavigation
            handleChange={this.handleChange}
            perPage={3}
            numPages={numContactPages || 2}
          >
            {({ items }) => this.addressBookContacts(items)}
          </Pagination>
        </div>
      </div>
    )
  }
}

AddressBook.defaultProps = {
  contacts: [],
  theme: null
}

function mapStateToProps (state) {
  const { bookingProcess, authentication } = state
  const { BookingDetails } = bookingProcess
  const { contactsData } = BookingDetails
  const { user } = authentication

  const {
    contacts, per_page, page, numContactPages
  } = contactsData || {}

  return {
    contacts, user, per_page, page, numContactPages
  }
}

function mapDispatchToProps (dispatch) {
  return {
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch)
  }
}
const connectedAddressBook = connect(mapStateToProps, mapDispatchToProps)(AddressBook)

export default withNamespaces(['account', 'common'])(connectedAddressBook)
