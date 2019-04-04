import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import Formsy from 'formsy-react'
import MailCheck from 'react-mailcheck'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route, withRouter } from 'react-router-dom'
import reactTriggerChange from 'react-trigger-change'
import PropTypes from '../../prop-types'
import { AdminClientsIndex, AdminClientView } from './'
import styles from './Admin.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { adminActions } from '../../actions'
import FormsyInput from '../FormsyInput/FormsyInput'
import GenericError from '../../components/ErrorHandling/Generic'

class AdminClients extends Component {
  static errorsExist (errorsObjects) {
    let returnBool = false
    errorsObjects.forEach((errorsObj) => {
      if (Object.values(errorsObj).indexOf(true) > -1) returnBool = true
    })

    return returnBool
  }

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
    this.toggleNewClient = this.toggleNewClient.bind(this)
    this.handleFormChange = this.handleFormChange.bind(this)
    this.saveNewClient = this.saveNewClient.bind(this)
    this.viewClient = this.viewClient.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.handleClientAction = this.handleClientAction.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
  }
  componentDidMount () {
    this.props.setCurrentUrl(this.props.match.url)
  }
  viewClient (client) {
    const { adminDispatch } = this.props
    adminDispatch.getClient(client.id, true)
  }

  backToIndex () {
    const { dispatch, history } = this.props
    dispatch(history.push('/admin/clients'))
  }
  handleClientAction (id, action) {
    const { adminDispatch } = this.props
    adminDispatch.confirmShipment(id, action)
  }
  resetTabIndex () {
    this.setState ({
      tabReset: true
    })
  }
  toggleNewClient () {
    this.setState({
      newClientBool: !this.state.newClientBool,
      newClientAttempt: false,
      tabReset: false
    })
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
    this.toggleNewClient()
    this.resetTabIndex()
  }

  handleInvalidSubmit () {
    if (!this.state.newClientAttempt) this.setState({ newClientAttempt: true })
  }

  render () {
    const { newClient, newClientBool, tabReset } = this.state
    const {
      t, theme, clients, hubs, hubHash, client, adminDispatch, scope, user
    } = this.props
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const errorStyle = {
      position: 'absolute',
      left: '15px',
      fontSize: '12px',
      bottom: '10px'
    }
    const mailCheckCallback = suggestion => (
      <div className="relative width_100">
        <FormsyInput
          wrapperClassName={styles.input_100}
          className={styles.input}
          errorMessageStyles={errorStyle}
          type="text"
          value={this.state.email}
          name="email"
          placeholder="Email *"
          onChange={(e) => {
            this.setState({ email: e.target.value })
          }}
          submitAttempted={this.state.newClientAttempt}
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
        {suggestion &&
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
        }
      </div>
    )

    const newClientBox = (
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
            submitAttempted={this.state.newClientAttempt}
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
            submitAttempted={this.state.newClientAttempt}
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: t('common:noBlank'),
              minLength: t('errors:twoChars')
            }}
            required
          />
          <MailCheck email={this.state.email}>
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
            submitAttempted={this.state.newClientAttempt}
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
            submitAttempted={this.state.newClientAttempt}
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
            submitAttempted={this.state.newClientAttempt}
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
            submitAttempted={this.state.newClientAttempt}
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
            submitAttempted={this.state.newClientAttempt}
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
            submitAttempted={this.state.newClientAttempt}
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
            submitAttempted={this.state.newClientAttempt}
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
                submitAttempted={this.state.newClientAttempt}
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
                submitAttempted={this.state.newClientAttempt}
                validations={{
                  matchesPassword: (values, value) =>
                    (this.tmpNewClient || newClient).password === value
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
    )

    return (
      <GenericError theme={theme}>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          {newClientBool ? newClientBox : ''}
          <Switch className="flex">
            <Route
              exact
              path="/admin/clients"
              render={props => (
                <AdminClientsIndex
                  theme={theme}
                  handleClientAction={this.handleClientAction}
                  clients={clients}
                  hubs={hubs}
                  user={user}
                  adminDispatch={adminDispatch}
                  viewClient={this.viewClient}
                  tabReset={tabReset}
                  scope={scope}
                  toggleNewClient={() => this.toggleNewClient()}
                  {...props}
                />
              )}
            />
            <Route
              exact
              path="/admin/clients/:id"
              render={props => (
                <AdminClientView
                  theme={theme}
                  hubHash={hubHash}
                  handleClientAction={this.handleClientAction}
                  clientData={client}
                  adminDispatch={adminDispatch}
                  {...props}
                />
              )}
            />
          </Switch>
        </div>
      </GenericError>
    )
  }
}

AdminClients.defaultProps = {
  theme: null,
  clients: [],
  hubs: [],
  hubHash: {}
}
function mapStateToProps (state) {
  const { authentication, app, admin } = state
  const { tenant } = app
  const { user, loggedIn } = authentication
  const { scope } = tenant
  const {
    clients, shipment, shipments, hubs, client
  } = admin

  return {
    user,
    tenant,
    loggedIn,
    clients,
    shipments,
    shipment,
    hubs,
    client,
    scope
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default withNamespaces(['admin', 'user', 'common', 'errors'])(withRouter(connect(mapStateToProps, mapDispatchToProps)(AdminClients)))
