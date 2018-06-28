import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route, withRouter } from 'react-router-dom'
import reactTriggerChange from 'react-trigger-change'
import PropTypes from '../../prop-types'
import { AdminClientsIndex, AdminClientView } from './'
import styles from './Admin.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { adminActions } from '../../actions'
import { ValidatedInput } from '../ValidatedInput/ValidatedInput'
// import { TextHeading } from '../TextHeading/TextHeading'
// import { adminClientsTooltips as clientTip } from '../../constants'
// import { Tooltip } from '../Tooltip/Tooltip'

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
      newClientAttempt: false
    }
    this.toggleNewClient = this.toggleNewClient.bind(this)
    this.handleFormChange = this.handleFormChange.bind(this)
    this.saveNewClient = this.saveNewClient.bind(this)
    this.viewClient = this.viewClient.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.handleClientAction = this.handleClientAction.bind(this)
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
  toggleNewClient () {
    this.setState({
      newClientBool: !this.state.newClientBool,
      newClientAttempt: false
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

  saveNewClient () {
    this.setState({ newClientAttempt: true })
    if (AdminClients.errorsExist([this.state.errors])) return

    const { newClient } = this.state
    const { adminDispatch } = this.props
    adminDispatch.newClient(newClient)
    this.toggleNewClient()
  }

  render () {
    const { newClient, newClientBool } = this.state
    const {
      theme, clients, hubs, client, adminDispatch
    } = this.props
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const newClientBox = (
      <div
        className={`flex-none layout-row layout-wrap layout-align-center-center ${
          styles.new_contact
        }`}
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
              <p className="flex-none">New Client</p>
            </div>
            <div
              className="flex-none layout-row layout-align-start-center"
              onClick={this.toggleNewClient}
            >
              <i className="fa fa-times flex-none clip pointy" style={textStyle} />
            </div>
          </div>
          <ValidatedInput
            wrapperClassName={styles.input_100}
            type="text"
            value={newClient.companyName}
            name="companyName"
            placeholder="Company Name *"
            onChange={this.handleFormChange}
            firstRenderInputs={!this.state.newClientAttempt}
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <ValidatedInput
            wrapperClassName={styles.input_50}
            type="text"
            value={newClient.firstName}
            name="firstName"
            placeholder="First Name *"
            onChange={this.handleFormChange}
            firstRenderInputs={!this.state.newClientAttempt}
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <ValidatedInput
            wrapperClassName={styles.input_50}
            type="text"
            value={newClient.lastName}
            name="lastName"
            placeholder="Last Name *"
            onChange={this.handleFormChange}
            firstRenderInputs={!this.state.newClientAttempt}
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <ValidatedInput
            wrapperClassName={styles.input_50}
            type="text"
            value={newClient.email}
            name="email"
            placeholder="Email *"
            onChange={this.handleFormChange}
            firstRenderInputs={!this.state.newClientAttempt}
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
          <ValidatedInput
            wrapperClassName={styles.input_50}
            type="text"
            value={newClient.phone}
            name="phone"
            placeholder="Phone *"
            onChange={this.handleFormChange}
            firstRenderInputs={!this.state.newClientAttempt}
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <ValidatedInput
            wrapperClassName={styles.input_street}
            type="text"
            value={newClient.street}
            name="street"
            placeholder="Street"
            onChange={this.handleFormChange}
            firstRenderInputs={!this.state.newClientAttempt}
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <ValidatedInput
            wrapperClassName={styles.input_no}
            type="text"
            value={newClient.number}
            name="number"
            placeholder="Number"
            onChange={this.handleFormChange}
            firstRenderInputs={!this.state.newClientAttempt}
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <ValidatedInput
            wrapperClassName={styles.input_zip}
            type="text"
            value={newClient.zipCode}
            name="zipCode"
            placeholder="Postal Code"
            onChange={this.handleFormChange}
            firstRenderInputs={!this.state.newClientAttempt}
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <ValidatedInput
            wrapperClassName={styles.input_cc}
            type="text"
            value={newClient.city}
            name="city"
            placeholder="City"
            onChange={this.handleFormChange}
            firstRenderInputs={!this.state.newClientAttempt}
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />
          <ValidatedInput
            wrapperClassName={styles.input_cc}
            type="text"
            value={newClient.country}
            name="country"
            placeholder="Country"
            onChange={this.handleFormChange}
            firstRenderInputs={!this.state.newClientAttempt}
            validations="minLength:2"
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              minLength: 'Must be at least two characters long'
            }}
            required
          />

          <div className="flex-100 layout-row">
            <div className="flex-50 layout-row layout-wrap">
              <ValidatedInput
                wrapperClassName={styles.input_100}
                type="password"
                value={newClient.password}
                name="password"
                placeholder="Password *"
                onChange={this.handleFormChange}
                firstRenderInputs={!this.state.newClientAttempt}
                validations="minLength:8"
                validationErrors={{
                  isDefaultRequiredValue: 'Must not be blank',
                  minLength: 'Must be at least 8 characters long'
                }}
                required
              />
            </div>
            <div className="flex-50 layout-row layout-wrap">
              <ValidatedInput
                inputRef={(input) => {
                  this.passwordConfirmationInput = input
                }}
                wrapperClassName={styles.input_100}
                type="password"
                value={newClient.password_confirmation}
                name="password_confirmation"
                placeholder="Password Confirmation *"
                onChange={this.handleFormChange}
                firstRenderInputs={!this.state.newClientAttempt}
                validations={{
                  matchesPassword: (values, value) =>
                    (this.tmpNewClient || newClient).password === value
                }}
                validationErrors={{
                  matchesPassword: 'Must match password',
                  isDefaultRequiredValue: 'Must not be blank'
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
              text="Save"
              handleNext={this.saveNewClient}
              iconClass="fa-floppy-o"
            />
          </div>
        </div>
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding_left">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div className="flex-none layout-row layout-align-start-center">
              {/* <div className="flex-none">
                <TextHeading theme={theme} size={1} text="Clients" />
              </div> */}
              {/* <Tooltip icon="fa-info-circle" theme={theme} toolText={clientTip.change} /> */}
            </div>
          </div>
        </div>
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
                adminDispatch={adminDispatch}
                viewClient={this.viewClient}
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
                hubs={hubs}
                handleClientAction={this.handleClientAction}
                clientData={client}
                adminDispatch={adminDispatch}
                {...props}
              />
            )}
          />
        </Switch>
      </div>
    )
  }
}
AdminClients.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hubs),
  clients: PropTypes.arrayOf(PropTypes.client),
  client: PropTypes.client.isRequired,
  adminDispatch: PropTypes.shape({
    getClient: PropTypes.func
  }).isRequired,
  dispatch: PropTypes.func.isRequired,
  history: PropTypes.history.isRequired
}
AdminClients.defaultProps = {
  theme: null,
  clients: [],
  hubs: []
}
function mapStateToProps (state) {
  const { authentication, tenant, admin } = state
  const { user, loggedIn } = authentication
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
    client
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(AdminClients))
