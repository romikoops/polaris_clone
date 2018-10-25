import React, { Component } from 'react'
import { translate } from 'react-i18next'
import Formsy from 'formsy-react'
import MailCheck from 'react-mailcheck'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import FormsyInput from '../FormsyInput/FormsyInput'
import PropTypes from '../../prop-types'
import { UserContactsIndex, UserContactsView } from './'
import styles from './UserAccount.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { userActions } from '../../actions'
import {
  gradientTextGenerator,
  emailServerValidation
} from '../../helpers'

const errorStyle = {
  position: 'absolute',
  left: '8px',
  fontSize: '12px',
  bottom: '-2px'
}

class UserContacts extends Component {
  constructor (props) {
    super(props)
    this.state = {
      newContactBool: false,
      newContact: {},
      submitAttempted: false,
      email: ''
    }
    this.viewContact = this.viewContact.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.handleClientAction = this.handleClientAction.bind(this)
    this.toggleNewContact = this.toggleNewContact.bind(this)
    this.handleValidSubmit = this.handleValidSubmit.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
  }

  componentDidMount () {
    window.scrollTo(0, 0)
    this.props.setCurrentUrl(this.props.match.url)
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
    this.setState({ newContactBool: !this.state.newContactBool, submitAttempted: false })
  }

  handleValidSubmit (contact, reset, invalidate) {
    this.setState({ submitAttempted: true })

    function handleResponse (data) {
      if (data.email === true) {
        invalidate({ email: this.props.t('errors:contactExists') })

        return
      }

      const { userDispatch, contactsData } = this.props
      userDispatch.newContact(contact, () => {
        userDispatch.getContacts({ page: 1, per_page: contactsData.per_page })
        this.setState({ email: '' })
      })
      this.toggleNewContact()
    }

    emailServerValidation('email', null, contact.email, handleResponse.bind(this))
  }

  handleInvalidSubmit () {
    if (!this.state.submitAttempted) this.setState({ submitAttempted: true })
  }

  render () {
    const {
      newContact, newContactBool, submitAttempted
    } = this.state
    const {
      theme, hubs, contactData, userDispatch, loading, t
    } = this.props

    const mailCheckCallback = suggestion => (
      <div className="relative width_100">
        <FormsyInput
          wrapperClassName={styles.input_100}
          className={styles.input}
          errorMessageStyles={errorStyle}
          submitAttempted={submitAttempted}
          type="text"
          value={this.state.email}
          onChange={(e) => {
            this.setState({ email: e.target.value })
          }}
          name="email"
          placeholder={t('user:email')}
          validations={{
            minLength: 2,
            matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
          }}
          validationErrors={{
            isDefaultRequiredValue: t('errors:notBlank'),
            minLength: t('errors:twoChars'),
            matchRegexp: t('errors:invalidEmail')
          }}
          required
        />
        {suggestion &&
            <div style={errorStyle}>
              {t('errors:didYouMean')}&nbsp;
              <span
                className="emulate_link blue_link"
                onClick={(e) => {
                  this.setState({ email: suggestion.full })
                }}
              >
                {suggestion.full}
              </span>?
            </div>
        }
      </div>
    )

    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start padding_top">
        <Switch className="flex">
          <Route
            exact
            path="/account/contacts"
            render={props => (
              <UserContactsIndex
                theme={theme}
                toggleNewContact={this.toggleNewContact}
                newContactBox={newContactBool && (
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
                      className={`flex-none layout-row layout-wrap layout-align-start-start ccb_contact_form ${
                        styles.new_contact_content
                      }`}
                      onValidSubmit={this.handleValidSubmit}
                      onInvalidSubmit={this.handleInvalidSubmit}
                      ref={(form) => { this.contactsForm = form }}
                    >
                      <div
                        className={` ${styles.contact_header} flex-100 layout-row layout-align-start-center`}
                      >
                        <i className="fa fa-user flex-none" style={textStyle} />
                        <p className="flex-none">{t('common:newContact')}</p>
                      </div>
                      <FormsyInput
                        wrapperClassName={styles.input_50}
                        className={styles.input}
                        errorMessageStyles={errorStyle}
                        submitAttempted={submitAttempted}
                        type="text"
                        value={newContact.firstName}
                        name="firstName"
                        placeholder={t('user:firstName')}
                        validations="minLength:2"
                        validationErrors={{
                          isDefaultRequiredValue: t('errors:notBlank'),
                          minLength: t('errors:twoChars')
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
                        placeholder={t('user:lastName')}
                        validations="minLength:2"
                        validationErrors={{
                          isDefaultRequiredValue: t('errors:notBlank'),
                          minLength: t('errors:twoChars')
                        }}
                        required
                      />
                      <FormsyInput
                        wrapperClassName={styles.input_60}
                        className={styles.input}
                        errorMessageStyles={errorStyle}
                        submitAttempted={submitAttempted}
                        type="text"
                        value={newContact.companyName}
                        name="companyName"
                        placeholder={t('user:companyName')}
                        validations="minLength:2"
                        validationErrors={{
                          isDefaultRequiredValue: t('errors:notBlank'),
                          minLength: t('errors:twoChars')
                        }}
                      />
                      <FormsyInput
                        wrapperClassName={styles.input_33}
                        className={styles.input}
                        errorMessageStyles={errorStyle}
                        submitAttempted={submitAttempted}
                        type="text"
                        value={newContact.phone}
                        name="phone"
                        placeholder={t('user:phone')}
                        validations="minLength:2"
                        validationErrors={{
                          isDefaultRequiredValue: t('errors:notBlank'),
                          minLength: t('errors:twoChars')
                        }}
                        required
                      />
                      <MailCheck email={this.state.email}>
                        {mailCheckCallback}
                      </MailCheck>
                      <FormsyInput
                        wrapperClassName={styles.input_50}
                        className={styles.input}
                        errorMessageStyles={errorStyle}
                        submitAttempted={submitAttempted}
                        type="text"
                        value={newContact.street}
                        name="street"
                        placeholder={t('user:street')}
                        validations="minLength:2"
                        validationErrors={{
                          isDefaultRequiredValue: t('errors:notBlank'),
                          minLength: t('errors:twoChars')
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
                        placeholder={t('user:streetNumber')}
                        validations="minLength:1"
                        validationErrors={{
                          isDefaultRequiredValue: t('errors:notBlank'),
                          minLength: t('errors:oneChar')
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
                        placeholder={t('user:postalCode')}
                        validations="minLength:2"
                        validationErrors={{
                          isDefaultRequiredValue: t('errors:notBlank'),
                          minLength: t('errors:twoChars')
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
                        placeholder={t('user:city')}
                        validations="minLength:2"
                        validationErrors={{
                          isDefaultRequiredValue: t('errors:notBlank'),
                          minLength: t('errors:twoChars')
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
                        placeholder={t('user:country')}
                        validations="minLength:4"
                        validationErrors={{
                          isDefaultRequiredValue: t('errors:notBlank'),
                          minLength: t('errors:fourChars')
                        }}
                      />
                      <div className={`flex-100 layout-row layout-align-end-center ${styles.btn_row}`}>
                        <RoundButton
                          theme={theme}
                          size="small"
                          active
                          text={t('common:save')}
                          iconClass="fa-floppy-o"
                        />
                      </div>
                    </Formsy>
                  </div>
                )}
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
  numPages: PropTypes.number,
  t: PropTypes.func.isRequired,
  match: PropTypes.match.isRequired,
  hubs: PropTypes.arrayOf(PropTypes.object),
  contactsData: PropTypes.arrayOf(PropTypes.contact),
  dispatch: PropTypes.func.isRequired,
  setCurrentUrl: PropTypes.func.isRequired,
  userDispatch: PropTypes.shape({
    getContact: PropTypes.func,
    getContacts: PropTypes.func,
    goTo: PropTypes.func,
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
  contactsData: [],
  numPages: 1,
  hubs: []
}

function mapStateToProps (state) {
  const { authentication, tenant, users } = state
  const { user, loggedIn } = authentication
  const {
    contactData, contactsData, hubs, loading
  } = users

  return {
    user,
    tenant,
    loggedIn,
    hubs,
    contactData,
    contactsData,
    loading
  }
}
function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch)
  }
}

export default translate(['user', 'errors'])(connect(mapStateToProps, mapDispatchToProps)(UserContacts))
