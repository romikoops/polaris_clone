import React, { Component } from 'react'
import Formsy from 'formsy-react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import FormsyInput from '../FormsyInput/FormsyInput'
import PropTypes from '../../prop-types'
import { UserContactsIndex, UserContactsView } from './'
import styles from './UserAccount.scss'
// import {v4} from 'uuid';
import { RoundButton } from '../RoundButton/RoundButton'
import { userActions } from '../../actions'
import {
  gradientTextGenerator,
  areEqual
} from '../../helpers'

class UserContacts extends Component {
  constructor (props) {
    super(props)
    this.state = {
      newContactBool: false,
      newContact: {},
      submitAttempted: false
    }
    this.viewContact = this.viewContact.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.handleClientAction = this.handleClientAction.bind(this)
    this.toggleNewContact = this.toggleNewContact.bind(this)
    // this.handleFormChange = this.handleFormChange.bind(this)
    // this.saveNewContact = this.saveNewContact.bind(this)
    this.handleValidSubmit = this.handleValidSubmit.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
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
  // handleFormChange (event) {
  //   const { name, value } = event.target
  //   this.setState({
  //     newContact: {
  //       ...this.state.newContact,
  //       [name]: value
  //     }
  //   })
  // }
  handleValidSubmit (contact, reset, invalidate) {
    const { contacts } = this.props

    this.setState({ submitAttempted: true })

    let shouldDispatch = true

    contacts.forEach((_contact) => {
      // debugger // eslint-disable-line no-debugger
      const contactWithLocation = {
        city: _contact.location && _contact.location.city,
        companyName: _contact.company_name,
        country: _contact.location && _contact.location.country && _contact.location.country.name,
        email: _contact.email,
        firstName: _contact.first_name,
        lastName: _contact.last_name,
        number: _contact.location && _contact.location.street_number,
        phone: _contact.phone,
        street: _contact.location && _contact.location.street,
        zipCode: _contact.location && _contact.location.zip_code
      }
      // debugger // eslint-disable-line no-debugger

      if (areEqual(contactWithLocation, contact)) {
        shouldDispatch = false

        invalidate((
          Object.keys(contact).reduce((acc, k) => ({ ...acc, [k]: 'Contact already exists.' }), {})
        ))
      }
    })

    if (!shouldDispatch) return

    const { userDispatch } = this.props
    userDispatch.newContact(contact)
    this.toggleNewContact()
  }

  handleInvalidSubmit () {
    if (!this.state.submitAttempted) this.setState({ submitAttempted: true })
  }

  render () {
    const { newContact, newContactBool, submitAttempted } = this.state
    const {
      theme, contacts, hubs, contactData, userDispatch, loading
    } = this.props

    const errorStyle = {
      position: 'absolute',
      left: '7px',
      fontSize: '12px',
      bottom: '-2px'
    }
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

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
        <Formsy
          className={`flex-none layout-row layout-wrap layout-align-start-start ${
            styles.new_contact_content
          }`}
          onValidSubmit={this.handleValidSubmit}
          onInvalidSubmit={this.handleInvalidSubmit}
        >
          <div
            className={` ${styles.contact_header} flex-100 layout-row layout-align-start-center`}
          >
            <i className="fa fa-user flex-none" style={textStyle} />
            <p className="flex-none">New Contact</p>
          </div>
          <FormsyInput
            wrapperClassName={styles.input_50}
            className={styles.input}
            errorMessageStyles={errorStyle}
            submitAttempted={submitAttempted}
            type="text"
            value={newContact.firstName}
            name="firstName"
            placeholder="First Name"
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <FormsyInput
            wrapperClassName={styles.input_50}
            className={styles.input}
            errorMessageStyles={errorStyle}
            submitAttempted={submitAttempted}
            type="text"
            value={newContact.lastName}
            name="lastName"
            placeholder="Last Name"
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <FormsyInput
            wrapperClassName={styles.input_100}
            className={styles.input}
            errorMessageStyles={errorStyle}
            submitAttempted={submitAttempted}
            type="text"
            value={newContact.companyName}
            name="companyName"
            placeholder="Company Name"
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
          />
          <FormsyInput
            wrapperClassName={styles.input_50}
            className={styles.input}
            errorMessageStyles={errorStyle}
            submitAttempted={submitAttempted}
            type="text"
            value={newContact.email}
            name="email"
            placeholder="email"
            validations={{
              minLength: 2,
              matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
            }}
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long',
              matchRegexp: 'Invalid email'
            }}
            required
          />
          <FormsyInput
            wrapperClassName={styles.input_50}
            className={styles.input}
            errorMessageStyles={errorStyle}
            submitAttempted={submitAttempted}
            type="text"
            value={newContact.phone}
            name="phone"
            placeholder="Phone"
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <FormsyInput
            wrapperClassName={styles.input_50}
            className={styles.input}
            errorMessageStyles={errorStyle}
            submitAttempted={submitAttempted}
            type="text"
            value={newContact.street}
            name="street"
            placeholder="Street"
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
          />
          <FormsyInput
            wrapperClassName={styles.input_50}
            className={styles.input}
            errorMessageStyles={errorStyle}
            submitAttempted={submitAttempted}
            type="text"
            value={newContact.number}
            name="number"
            placeholder="Street Number"
            validations="minLength:1"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least one character long'
            }}
          />
          <FormsyInput
            wrapperClassName={styles.input_33}
            className={styles.input}
            errorMessageStyles={errorStyle}
            submitAttempted={submitAttempted}
            type="text"
            value={newContact.zipCode}
            name="zipCode"
            placeholder="Postal Code"
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
          />
          <FormsyInput
            wrapperClassName={styles.input_33}
            className={styles.input}
            errorMessageStyles={errorStyle}
            submitAttempted={submitAttempted}
            type="text"
            value={newContact.city}
            name="city"
            placeholder="City"
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
          />
          <FormsyInput
            wrapperClassName={styles.input_33}
            className={styles.input}
            errorMessageStyles={errorStyle}
            submitAttempted={submitAttempted}
            type="text"
            value={newContact.country}
            name="country"
            placeholder="Country"
            validations="minLength:4"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least four characters long'
            }}
          />
          <div className={`flex-100 layout-row layout-align-end-center ${styles.btn_row}`}>
            <RoundButton
              theme={theme}
              size="small"
              active
              text="Save"
              iconClass="fa-floppy-o"
            />
          </div>
        </Formsy>
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start padding_top">
        <Switch className="flex">
          <Route
            exact
            path="/account/contacts"
            render={props => (
              <UserContactsIndex
                theme={theme}
                loading={loading}
                newContactBox={newContactBool ? newContactBox : ''}
                toggleNewContact={this.toggleNewContact}
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
