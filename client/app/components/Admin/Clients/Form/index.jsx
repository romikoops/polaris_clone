import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import MailCheck from 'react-mailcheck'
import reactTriggerChange from 'react-trigger-change'
import { bindActionCreators } from 'redux'
import { clientsActions, adminActions } from '../../../../actions'
import styles from '../index.scss'
import FormsyInput from '../FormsyInput/FormsyInput'
import GreyBox from '../../../GreyBox/GreyBox'
import RoundButton from '../../../RoundButton/RoundButton'

class AdminClientForm extends Component {
  constructor (props) {
    super(props)
    this.state = {
      newClientBool: false,
      newClient: {},
      tabReset: false,
      errors: {
        companyName: true,
        firstName: true,
        lastName: true,
        email: true,
        phone: true,
        street: true,
        number: true,
        zipCode: true,
        city: true,
        country: true,
        password: true,
        password_confirmation: true
      },
      email: '',
      newClientAttempt: false
    }
    this.handleFormChange = this.handleFormChange.bind(this)
    this.saveNewClient = this.saveNewClient.bind(this)
    this.handleClientAction = this.handleClientAction.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
  }

  handleClientAction (id, action) {
    const { adminDispatch } = this.props
    adminDispatch.confirmShipment(id, action)
  }

  handleFormChange (event, hasError) {
    const { name, value } = event.target
    const { errors } = this.state

    const { newClient } = this.state
    if (this.tmpNewClient) {
      Object.assign(newClient, this.tmpNewClient)
      Object.assign(errors, this.tmpErrors)
      this.tmpNewClient = null
    }

    if (hasError !== undefined) errors[name] = hasError

    if (name === 'password' && this.passwordConfirmationInput) {
      this.tmpNewClient = {
        ...this.state.newClient,
        [name]: value
      }
      this.tmpErrors = Object.assign({}, errors)
      reactTriggerChange(this.passwordConfirmationInput)
    } else {
      this.setState({
        newClient: {
          ...newClient,
          [name]: value
        },
        errors
      })
    }
  }

  saveNewClient (client, reset, invalidate) {
    const { clients } = this.props
    this.setState({ newClientAttempt: true })
    let shouldDispatch = true

    clients.forEach((_client) => {
      if (_client.email === client.email) {
        shouldDispatch = false
        invalidate({ email: 'Email already exists.' })
      }
    })

    if (!shouldDispatch) return

    const { adminDispatch } = this.props
    adminDispatch.newClient(client)
  }

  handleInvalidSubmit () {
    if (!this.state.newClientAttempt) this.setState({ newClientAttempt: true })
  }

  render () {
    const { t, theme } = this.props
    const { newClient, newClientAttempt, email } = this.state

    const mailCheckCallback = suggestion => (
      <div className="relative width_100">
        <FormsyInput
          wrapperClassName={styles.input_100}
          className={styles.input}
          errorMessageStyles={errorStyle}
          type="text"
          value={email}
          name="email"
          placeholder="Email *"
          onChange={(e) => {
            this.setState({ email: e.target.value })
          }}
          submitAttempted={newClientAttempt}
          validations={{
            minLength: 2,
            matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
          }}
          validationErrors={{
            isDefaultRequiredValue: t('common:noBlank'),
            minLength: t('errors:twoChars'),
            matchRegexp: t('errors:invalidEmail')
          }}
          required
        />
        {suggestion && (
<div style={errorStyle}>
              Did you mean&nbsp;
              <span
                className="emulate_link blue_link"
                onClick={(e) => {
                  this.setState({ email: suggestion.full })
                }}
              >
                {suggestion.full}
              </span>?
            </div>
)}
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap padding_top">

        <div className="flex-100 flex-gt-sm-25 layout-row layout-wrap layout-align-center-start">
          <GreyBox
            wrapperClassName="flex-100"
            contentClassName="flex-100 layout-row layout-wrap layout-align-center-start"
          >
            <Formsy
              className={`flex-none layout-row layout-wrap layout-align-center-center ${
                styles.new_contact
              }`
              }
              onValidSubmit={this.saveNewClient}
              onInvalidSubmit={this.handleInvalidSubmit}
            >
              <div
                className={`flex-none layout-row layout-wrap layout-align-center-center ${
                  styles.new_contact_backdrop
                }`}
                onClick={this.toggleNewClient}
              />
              <div
                className={`flex-none layout-row layout-wrap layout-align-start-start ${
                  styles.new_contact_content
                }`}
              >
                <div
                  className={` ${
                    styles.contact_header
                  } flex-100 layout-row layout-align-space-between-center`}
                >
                  <div className="flex-none layout-row layout-align-start-center">
                    <i className="fa fa-user flex-none clip" style={textStyle} />
                    <p className="flex-none">{t('admin:newClient')}</p>
                  </div>
                  <div
                    className="flex-none layout-row layout-align-start-center"
                    onClick={this.toggleNewClient}
                  >
                    <i className="fa fa-times flex-none clip pointy" style={textStyle} />
                  </div>
                </div>
                <FormsyInput
                  wrapperClassName={styles.input_50}
                  className={styles.input}
                  errorMessageStyles={errorStyle}
                  type="text"
                  value={newClient.firstName}
                  name="firstName"
                  placeholder={`${t('user:firstName')} *`}
                  onChange={this.handleFormChange}
                  submitAttempted={newClientAttempt}
                  validations="minLength:2"
                  validationErrors={{
                    isDefaultRequiredValue: t('common:noBlank'),
                    minLength: t('errors:twoChars')
                  }}
                  required
                />
                <FormsyInput
                  wrapperClassName={styles.input_50}
                  className={styles.input}
                  errorMessageStyles={errorStyle}
                  type="text"
                  value={newClient.lastName}
                  name="lastName"
                  placeholder={`${t('user:lastName')} *`}
                  onChange={this.handleFormChange}
                  submitAttempted={newClientAttempt}
                  validations="minLength:2"
                  validationErrors={{
                    isDefaultRequiredValue: t('common:noBlank'),
                    minLength: t('errors:twoChars')
                  }}
                  required
                />
                <MailCheck email={email}>
                  {mailCheckCallback}
                </MailCheck>
                <FormsyInput
                  wrapperClassName={styles.input_33}
                  className={styles.input}
                  errorMessageStyles={errorStyle}
                  type="text"
                  value={newClient.phone}
                  name="phone"
                  placeholder={`${t('user:phone')} *`}
                  onChange={this.handleFormChange}
                  submitAttempted={newClientAttempt}
                  validations="minLength:2"
                  validationErrors={{
                    isDefaultRequiredValue: t('common:noBlank'),
                    minLength: t('errors:twoChars')
                  }}
                  required
                />
                <FormsyInput
                  wrapperClassName={styles.input_60}
                  className={styles.input}
                  errorMessageStyles={errorStyle}
                  type="text"
                  value={newClient.companyName}
                  name="companyName"
                  placeholder={`${t('user:companyName')} *`}
                  onChange={this.handleFormChange}
                  submitAttempted={newClientAttempt}
                  validations="minLength:2"
                  validationErrors={{
                    isDefaultRequiredValue: t('common:noBlank'),
                    minLength: t('errors:twoChars')
                  }}
                  required
                />
                <FormsyInput
                  wrapperClassName={styles.input_no}
                  className={styles.input}
                  errorMessageStyles={errorStyle}
                  type="text"
                  value={newClient.number}
                  name="number"
                  placeholder={t('user:number')}
                  onChange={this.handleFormChange}
                  submitAttempted={newClientAttempt}
                  validations="minLength:1"
                  validationErrors={{
                    isDefaultRequiredValue: t('common:noBlank'),
                    minLength: t('errors:oneChar')
                  }}
                />
                <FormsyInput
                  wrapperClassName={styles.input_street}
                  className={styles.input}
                  errorMessageStyles={errorStyle}
                  type="text"
                  value={newClient.street}
                  name="street"
                  placeholder={t('user:street')}
                  onChange={this.handleFormChange}
                  submitAttempted={newClientAttempt}
                  validations="minLength:2"
                  validationErrors={{
                    isDefaultRequiredValue: t('common:noBlank'),
                    minLength: t('errors:twoChars')
                  }}
                />
                <FormsyInput
                  wrapperClassName={styles.input_zip}
                  className={styles.input}
                  errorMessageStyles={errorStyle}
                  type="text"
                  value={newClient.zipCode}
                  name="zipCode"
                  placeholder={t('user:postalCode')}
                  onChange={this.handleFormChange}
                  submitAttempted={newClientAttempt}
                  validations="minLength:2"
                  validationErrors={{
                    isDefaultRequiredValue: t('common:noBlank'),
                    minLength: t('errors:twoChars')
                  }}
                />
                <FormsyInput
                  wrapperClassName={styles.input_cc}
                  className={styles.input}
                  errorMessageStyles={errorStyle}
                  type="text"
                  value={newClient.city}
                  name="city"
                  placeholder={t('user:city')}
                  onChange={this.handleFormChange}
                  submitAttempted={newClientAttempt}
                  validations="minLength:2"
                  validationErrors={{
                    isDefaultRequiredValue: t('common:noBlank'),
                    minLength: t('errors:twoChars')
                  }}
                />
                <FormsyInput
                  wrapperClassName={styles.input_cc}
                  className={styles.input}
                  errorMessageStyles={errorStyle}
                  type="text"
                  value={newClient.country}
                  name="country"
                  placeholder={t('user:country')}
                  onChange={this.handleFormChange}
                  submitAttempted={newClientAttempt}
                  validations="minLength:2"
                  validationErrors={{
                    isDefaultRequiredValue: t('common:noBlank'),
                    minLength: t('errors:twoChars')
                  }}
                />

                <div className="flex-100 layout-row">
                  <div className="flex-50 layout-row layout-wrap">
                    <FormsyInput
                      wrapperClassName={styles.input_100}
                      className={styles.input}
                      errorMessageStyles={errorStyle}
                      type="password"
                      value={newClient.password}
                      name="password"
                      placeholder={t('admin:password')}
                      onChange={this.handleFormChange}
                      submitAttempted={newClientAttempt}
                      validations="minLength:8"
                      validationErrors={{
                        isDefaultRequiredValue: t('common:noBlank'),
                        minLength: t('errors:eightChars')
                      }}
                      required
                    />
                  </div>
                  <div className="flex-50 layout-row layout-wrap">
                    <FormsyInput
                      inputRef={(input) => {
                        this.passwordConfirmationInput = input
                      }}
                      wrapperClassName={styles.input_100}
                      className={styles.input}
                      errorMessageStyles={errorStyle}
                      type="password"
                      value={newClient.password_confirmation}
                      name="password_confirmation"
                      placeholder={t('admin:passwordConfirmation')}
                      onChange={this.handleFormChange}
                      submitAttempted={newClientAttempt}
                      validations={{
                        matchesPassword: (values, value) => (this.tmpNewClient || newClient).password === value
                      }}
                      validationErrors={{
                        matchesPassword: t('errors:mustMatchPassword'),
                        isDefaultRequiredValue: t('common:noBlank')
                      }}
                      required
                    />
                  </div>
                </div>

                <div className={`flex-100 layout-row layout-align-end-center ${styles.btn_row}`}>
                  <RoundButton
                    theme={theme}
                    size="small"
                    active
                    text={t('admin:save')}
                    iconClass="fa-floppy-o"
                  />
                </div>
              </div>
            </Formsy>
          </GreyBox>
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { app } = state
  const { tenant } = app
  const { theme } = tenant

  return {
    theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch),
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientForm))
