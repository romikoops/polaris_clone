import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import styles from './ContactSetter.scss'
import defs from '../../styles/default_classes.scss'
import { Modal } from '../Modal/Modal'
import ContactSetterBody from './Body'
import ContactSetterNewContactWrapper from './NewContactWrapper'
import { bookingProcessActions } from '../../actions'
// eslint-disable-next-line no-named-as-default
import ShipmentContactForm from '../ShipmentContactForm/ShipmentContactForm'

class ContactSetter extends Component {
  constructor (props) {
    super(props)

    this.contactTypes = props.direction === 'export'
      ? ['shipper', 'consignee', 'notifyee']
      : ['consignee', 'shipper', 'notifyee']

    this.state = {
      modal: '',
      showModal: false,
      contactData: {
        contact: {},
        address: {}
      }
    }

    this.showAddressBook = this.showAddressBook.bind(this)
    this.showEditContact = this.showEditContact.bind(this)
  }

  autofillContact (contactData) {
    this.setState({
      contactData: {
        ...this.state.contactData,
        contact: contactData.contact,
        address: contactData.address
      }
    })
  }

  toggleShowModal () {
    this.setState({ showModal: !this.state.showModal })
  }

  showAddressBook (contactType, index) {
    const {
      shipper, consignee, notifyees, theme, setContact
    } = this.props
    const modal = (
      <Modal
        component={(
          <ContactSetterNewContactWrapper
            AddressBookProps={{
              theme,
              contactType,
              setContacts: [shipper, consignee, ...notifyees],
              setContact: (contactData) => {
                setContact(contactData, contactType, index)
                this.setState({
                  modal: null,
                  showModal: false
                })
              }
            }}
            ShipmentContactFormProps={{
              contactType,
              theme,
              selectedContact: { contact: {}, address: {} },
              setContact: (contactData) => {
                setContact(contactData, contactType, index)
                this.setState({ modal: null, showModal: false })
              }
            }}
            contactType={contactType}
          />
        )}
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={() => this.toggleShowModal()}
      />
    )
    this.setState({ modal, showModal: true })
  }

  showEditContact (contactType, index) {
    const {
      shipper, consignee, notifyees, contacts, shipmentDispatch
    } = this.props

    let newSelectedContact
    if (contactType === 'shipper') {
      newSelectedContact = shipper
    } else if (contactType === 'consignee') {
      newSelectedContact = consignee
    } else {
      newSelectedContact = notifyees[index]
    }
    const modal = (
      <Modal
        flexOptions="flex-80"
        component={(
          <ShipmentContactForm
            showEdit
            selectedContact={newSelectedContact}
            theme={this.props.theme}
            contacts={contacts}
            shipmentDispatch={shipmentDispatch}
            setContact={(contactData) => {
              this.props.setContact(contactData, contactType, index)
              this.setState({ modal: null, showModal: false })
            }}
            contactType={contactType}
          />
        )}
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={() => this.toggleShowModal()}
      />
    )
    this.setState({ modal, showModal: true })
  }

  render () {
    const {
      theme, shipper, consignee, notifyees, t
    } = this.props
    const { showModal, modal } = this.state

    return (
      <div
        name="contact_setter"
        className={
          `${styles.contact_setter} flex-100 ` +
          'layout-row layout-wrap layout-align-center-start'
        }
      >
        {showModal && modal}
        <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
          <div
            className={`${styles.wrapper_main_h1} flex-100`}
            onClick={null}
          >

            <h1>{t('account:setContact')}</h1>
            <hr className={styles.main_hr} />
          </div>
          <div
            className="flex-100 layout-row layout-align-center-center"
          >
            <ContactSetterBody
              consignee={consignee}
              shipper={shipper}
              notifyees={notifyees}
              direction={this.props.direction}
              theme={theme}
              removeNotifyee={this.props.removeNotifyee}
              showEditContact={(contactType, index) => this.showEditContact(contactType, index)}
              showAddressBook={(contactType, index) => this.showAddressBook(contactType, index)}
              setContactForEdit={this.setContactForEdit}
              finishBookingAttempted={this.props.finishBookingAttempted}
            />
          </div>

          <hr className={`${styles.main_hr} ${styles.bottom_hr}`} />
        </div>
      </div>
    )
  }
}

ContactSetter.defaultProps = {
  shipper: {},
  consignee: {},
  notifyees: [],
  contacts: [],
  theme: null,
  finishBookingAttempted: false
}

export default withNamespaces(['common', 'errors'])(ContactSetter)
