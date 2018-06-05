import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from '../../prop-types'
import { UserContactsIndex, UserContactsView } from './'
import styles from './UserAccount.scss'
// import {v4} from 'uuid';
import { RoundButton } from '../RoundButton/RoundButton'
import { userActions } from '../../actions'
import { gradientTextGenerator } from '../../helpers'

class UserContacts extends Component {
  constructor (props) {
    super(props)
    this.state = {
      newContactBool: false,
      newContact: {}
    }
    this.viewContact = this.viewContact.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.handleClientAction = this.handleClientAction.bind(this)
    this.toggleNewContact = this.toggleNewContact.bind(this)
    this.handleFormChange = this.handleFormChange.bind(this)
    this.saveNewContact = this.saveNewContact.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  viewContact (contact) {
    const { userDispatch } = this.props
    userDispatch.getContact(contact.id, true)
  }

  backToIndex () {
    const { dispatch, history } = this.props
    dispatch(history.push('/admin/contacts'))
  }
  handleClientAction (id, action) {
    const { userDispatch } = this.props
    userDispatch.confirmShipment(id, action)
  }
  toggleNewContact () {
    this.setState({ newContactBool: !this.state.newContactBool })
  }
  handleFormChange (event) {
    const { name, value } = event.target
    this.setState({
      newContact: {
        ...this.state.newContact,
        [name]: value
      }
    })
  }
  saveNewContact () {
    const { newContact } = this.state
    const { userDispatch } = this.props
    userDispatch.newContact(newContact)
    this.toggleNewContact()
  }

  render () {
    const { newContact, newContactBool } = this.state
    const {
      theme, contacts, hubs, contactData, userDispatch, loading
    } = this.props
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const newButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="New"
          active
          handleNext={this.toggleNewContact}
          iconClass="fa-plus"
        />
      </div>
    )
    const newContactBox = (
      <div
        className={`flex-none layout-row layout-wrap layout-align-center-center ${
          styles.new_contact
        }`}
      >
        <div
          className={`flex-none layout-row layout-wrap layout-align-center-center ${
            styles.new_contact_backdrop
          }`}
          onClick={this.toggleNewContact}
        />
        <div
          className={`flex-none layout-row layout-wrap layout-align-start-start ${
            styles.new_contact_content
          }`}
        >
          <div
            className={` ${styles.contact_header} flex-100 layout-row layout-align-start-center`}
          >
            <i className="fa fa-user flex-none" style={textStyle} />
            <p className="flex-none">New Contact</p>
          </div>
          <input
            className={styles.input_100}
            type="text"
            value={newContact.companyName}
            name="companyName"
            placeholder="Company Name"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_50}
            type="text"
            value={newContact.firstName}
            name="firstName"
            placeholder="First Name"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_50}
            type="text"
            value={newContact.lastName}
            name="lastName"
            placeholder="Last Name"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_50}
            type="text"
            value={newContact.email}
            name="email"
            placeholder="Email"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_50}
            type="text"
            value={newContact.phone}
            name="phone"
            placeholder="Phone"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_street}
            type="text"
            value={newContact.street}
            name="street"
            placeholder="Street"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_no}
            type="text"
            value={newContact.number}
            name="number"
            placeholder="Number"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_zip}
            type="text"
            value={newContact.zipCode}
            name="zipCode"
            placeholder="Postal Code"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_cc}
            type="text"
            value={newContact.city}
            name="city"
            placeholder="City"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_cc}
            type="text"
            value={newContact.country}
            name="country"
            placeholder="Country"
            onChange={this.handleFormChange}
          />
          <div className={`flex-100 layout-row layout-align-end-center ${styles.btn_row}`}>
            <RoundButton
              theme={theme}
              size="small"
              active
              text="Save"
              handleNext={this.saveNewContact}
              iconClass="fa-floppy-o"
            />
          </div>
        </div>
      </div>
    )
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        {newContactBool ? newContactBox : ''}
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          {newButton}
        </div>
        <Switch className="flex">
          <Route
            exact
            path="/account/contacts"
            render={props => (
              <UserContactsIndex
                theme={theme}
                loading={loading}
                handleClientAction={this.handleClientAction}
                contacts={contacts}
                hubs={hubs}
                userDispatch={userDispatch}
                viewContact={this.viewContact}
                {...props}
              />
            )}
          />
          <Route
            exact
            path="/account/contacts/:id"
            render={props => (
              <UserContactsView
                theme={theme}
                loading={loading}
                hubs={hubs}
                handleClientAction={this.handleClientAction}
                userDispatch={userDispatch}
                contactData={contactData}
                {...props}
              />
            )}
          />
        </Switch>
      </div>
    )
  }
}
UserContacts.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.object),
  contacts: PropTypes.arrayOf(PropTypes.object),
  dispatch: PropTypes.func.isRequired,
  userDispatch: PropTypes.shape({
    getContact: PropTypes.func,
    confirmShipment: PropTypes.func
  }).isRequired,
  history: PropTypes.history.isRequired,
  loading: PropTypes.bool,
  contactData: PropTypes.shape({
    contact: PropTypes.contact,
    shipments: PropTypes.shipments,
    location: PropTypes.location
  }).isRequired
}

UserContacts.defaultProps = {
  theme: null,
  loading: false,
  contacts: null,
  hubs: []
}

function mapStateToProps (state) {
  const { authentication, tenant, users } = state
  const { user, loggedIn } = authentication
  const {
    contactData, dashboard, hubs, loading
  } = users
  const { contacts } = dashboard

  return {
    user,
    tenant,
    loggedIn,
    contacts,
    hubs,
    contactData,
    loading
  }
}
function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(UserContacts)
