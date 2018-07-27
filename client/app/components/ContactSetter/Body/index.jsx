import React, { Component } from 'react'
import PropTypes from '../../../prop-types'
// import styles from './Body.scss'
import defs from '../../../styles/default_classes.scss'
import ShipmentContactsBoxMainContacts from './MainContacts'
import ShipmentContactsBoxNotifyeeContacts from './NotifyeeContacts'
import { gradientTextGenerator } from '../../../helpers'
import styles from '../../UserAccount/UserAccount.scss'
import { RoundButton } from '../../RoundButton/RoundButton'

const EditProfileBox = ({
  user, handleChange, onSave, close, style, theme
}) => (
  <div className="flex-60 layout-row layout-align-start-start layout-wrap">
    <div className="flex-100 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
            Company
        </sup>
      </div>
      <div className="input_box_full flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-100"
          type="text"
          value={user.company_name}
          onChange={handleChange}
          name="company_name"
        />
      </div>
    </div>
    <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
            First Name
        </sup>
      </div>
      <div className="input_box_full flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.first_name}
          onChange={handleChange}
          name="first_name"
        />
      </div>
    </div>
    <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
            Last Name
        </sup>
      </div>
      <div className="input_box_full flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.last_name}
          onChange={handleChange}
          name="last_name"
        />
      </div>
    </div>
    <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
            Email
        </sup>
      </div>
      <div className="input_box_full flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.email}
          onChange={handleChange}
          name="email"
        />
      </div>
    </div>
    <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
            Phone
        </sup>
      </div>
      <div className="input_box_full flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.phone}
          onChange={handleChange}
          name="phone"
        />
      </div>
    </div>
    <div className="flex-100 layout-row layout-align-end-center layout-wrap">
      <div className="flex-100 flex-gt-sm-25 layout-row layout-align-center-center button_padding">
        <RoundButton
          theme={theme}
          handleNext={close}
          size="small"
          text="close"
          iconClass="fa-times"
        />
      </div>
      <div className="flex-100 flex-gt-sm-25 layout-row layout-align-center-center button_padding">
        <RoundButton
          theme={theme}
          handleNext={onSave}
          active
          size="small"
          text="Save"
          iconClass="fa-floppy-o"
        />
      </div>
    </div>
  </div>
)

EditProfileBox.propTypes = {
  user: PropTypes.user.isRequired,
  handleChange: PropTypes.func.isRequired,
  onSave: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired,
  style: PropTypes.objectOf(PropTypes.string),
  theme: PropTypes.theme
}

EditProfileBox.defaultProps = {
  theme: null,
  style: {}
}

export default class ShipmentContactsBox extends Component {
  constructor (props) {
    super(props)
    this.state = {
      editBool: false,
      editObj: {}
    }
    this.newContactData = {
      contact: {
        companyName: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: ''
      },
      location: {
        street: '',
        number: '',
        zipCode: '',
        city: '',
        country: '',
        gecodedAddress: ''
      }
    }
  }

  setContactForEdit (contactData, contactType, contactIndex) {
    this.props.setContactForEdit({
      ...contactData,
      type: contactType,
      index: contactIndex
    })
  }

  goBack () {
    const { userDispatch } = this.props
    userDispatch.goBack()
  }
  editProfile () {
    const { contactData } = this.props
    const { contact } = contactData
    this.setState({
      editBool: true,
      editObj: contact
    })
  }
  closeEdit () {
    this.setState({
      editBool: false
    })
  }
  handleChange (ev) {
    const { name, value } = ev.target
    this.setState({
      editObj: {
        ...this.state.editObj,
        [name]: value
      }
    })
  }
  saveEdit () {
    const { userDispatch } = this.props
    userDispatch.updateContact(this.state.editObj)
    this.closeEdit()
  }

  render () {
    const {
      shipper, consignee, notifyees, theme, direction, showAddressBook, showEditContact, handleClick
    } = this.props
    const { editBool, editObj } = this.state

    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
          {editBool ? (
            <div className="flex-100 layout-row layout-wrap">
              <EditProfileBox
                user={editObj}
                style={textStyle}
                theme={theme}
                handleChange={this.handleChange}
                onSave={this.saveEdit}
                close={this.closeEdit}
              />
            </div>
          ) : (
            <div className="flex-100 layout-row layout-wrap">
              <div className="flex-100 layout-row layout-wrap">
                <ShipmentContactsBoxMainContacts
                  theme={theme}
                  shipper={shipper}
                  consignee={consignee}
                  handleClick={handleClick}
                  direction={direction}
                  showEditContact={showEditContact}
                  showAddressBook={showAddressBook}
                />
              </div>
              <div className="flex-100 layout-row layout-wrap">
                <ShipmentContactsBoxNotifyeeContacts
                  theme={theme}
                  showEditContact={showEditContact}
                  notifyees={notifyees}
                  showAddressBook={showAddressBook}
                  removeFunc={this.props.removeNotifyee}
                />
              </div>
            </div>
          )}

        </div>
      </div>
    )
  }
}
ShipmentContactsBox.propTypes = {
  theme: PropTypes.theme,
  removeNotifyee: PropTypes.func.isRequired,
  consignee: PropTypes.shape({
    companyName: PropTypes.string,
    firstName: PropTypes.string,
    lastName: PropTypes.string,
    email: PropTypes.string,
    phone: PropTypes.string,
    street: PropTypes.string,
    number: PropTypes.string,
    zipCode: PropTypes.string,
    city: PropTypes.string,
    country: PropTypes.string
  }).isRequired,
  shipper: PropTypes.shape({
    companyName: PropTypes.string,
    firstName: PropTypes.string,
    lastName: PropTypes.string,
    email: PropTypes.string,
    phone: PropTypes.string,
    street: PropTypes.string,
    number: PropTypes.string,
    zipCode: PropTypes.string,
    city: PropTypes.string,
    country: PropTypes.string
  }).isRequired,
  notifyees: PropTypes.arrayOf(PropTypes.shape({
    companyName: PropTypes.string,
    firstName: PropTypes.string,
    lastName: PropTypes.string,
    email: PropTypes.string,
    phone: PropTypes.string,
    street: PropTypes.string,
    number: PropTypes.string,
    zipCode: PropTypes.string,
    city: PropTypes.string,
    country: PropTypes.string
  })),
  setContactForEdit: PropTypes.func.isRequired,
  direction: PropTypes.string.isRequired,
  showAddressBook: PropTypes.func.isRequired
  // finishBookingAttempted: PropTypes.bool
}

ShipmentContactsBox.defaultProps = {
  theme: null,
  notifyees: []
  // finishBookingAttempted: false
}
