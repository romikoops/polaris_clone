import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import Formsy from 'formsy-react'
import PropTypes from '../../prop-types'
import { authenticationActions } from '../../actions'
import { RoundButton } from '../../components/RoundButton/RoundButton'
import { LoadingSpinner } from '../../components/LoadingSpinner/LoadingSpinner'
import RegistrationFormGroup from './components/RegistrationFormGroup'
import TermsAndConditionsSummary from './components/TermsAndConditionsSummary'
import styles from './RegistrationPage.scss'

class RegistrationPage extends React.PureComponent {
  static mapInputs (inputs) {
    const addressInputs = ['street', 'number', 'zip_code', 'city', 'country']
    const model = { address: {} }
    Object.keys(inputs).forEach((inputName) => {
      if (inputName === 'number') {
        model.address.street_number = inputs.number
      } else if (addressInputs.includes(inputName)) {
        model.address[inputName] = inputs[inputName]
      } else {
        model[inputName] = inputs[inputName]
      }
    })
    return model
  }

  constructor (props) {
    super(props)
    this.state = {
      focus: {},
      termsAndConditionsAccepted: {
        imc: false,
        tenant: false
      }
    }

    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.allAccepted = this.allAccepted.bind(this)
    this.shakeInvalidCheckboxes = this.shakeInvalidCheckboxes.bind(this)
  }

  handleFocus (e) {
    this.setState({
      focus: {
        ...this.state.focus,
        [e.target.name]: e.type === 'focus'
      }
    })
  }

  handleChangeTermsAndConditionsAccepted (value, e) {
    const key = e.target.name.split('-')[0]
    this.setState(prevState => ({
      termsAndConditionsAccepted: {
        ...prevState.termsAndConditionsAccepted,
        [key]: value
      }
    }))
  }

  handleSubmit (model) {
    if (!this.allAccepted()) {
      this.shakeInvalidCheckboxes()
      return
    }
    const user = Object.assign({}, model)
    user.tenant_id = this.props.tenant.id
    user.guest = false

    const { req, authenticationDispatch } = this.props
    if (req) {
      authenticationDispatch.updateUser(this.props.user, user, req)
    } else {
      authenticationDispatch.register(user)
    }
  }

  handleInvalidSubmit () {
    if (!this.allAccepted()) {
      this.shakeInvalidCheckboxes()
      return
    }
    if (!this.state.submitAttempted) this.setState({ submitAttempted: true })
  }

  allAccepted () {
    return Object.values(this.state.termsAndConditionsAccepted).every(bool => bool)
  }

  shakeInvalidCheckboxes () {
    this.setState(prevState => ({
      shakeClass: {
        imc: prevState.termsAndConditionsAccepted.imc ? '' : 'apply_shake',
        tenant: prevState.termsAndConditionsAccepted.tenant ? '' : 'apply_shake'
      }
    }))
    setTimeout(() => {
      this.setState({
        shakeClass: {
          imc: '',
          tenant: ''
        }
      })
    }, 1000)
  }

  render () {
    const {
      registering, theme, tenant, authenticationDispatch
    } = this.props

    const sharedProps = {
      handleFocus: e => this.handleFocus(e),
      focus: this.state.focus,
      submitAttempted: this.state.submitAttempted,
      theme
    }

    return (
      <Formsy
        className={styles.registration_form}
        name="form"
        onValidSubmit={this.handleSubmit}
        onInvalidSubmit={this.handleInvalidSubmit}
        mapping={RegistrationPage.mapInputs}
      >
        <div className="flex-100 layout-row layout-wrap">
          <div className="flex-100">
            <h3>Account Details</h3>
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div className="flex-45 layout-row layout-align-center-center">
              <RegistrationFormGroup field="first_name" minLength="2" {...sharedProps} />
            </div>
            <div className="flex-45 layout-row layout-align-center-center">
              <RegistrationFormGroup field="last_name" minLength="2" {...sharedProps} />
            </div>
          </div>
          <div className="flex-100">
            
            <RegistrationFormGroup
              field="email"
              minLength="2"
              validations={{ matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }}
              validationErrors={{ matchRegexp: 'Invalid email' }}
              {...sharedProps}
            />

            <RegistrationFormGroup
              field="password"
              minLength="8"
              type="password"
              {...sharedProps}
            />
            <RegistrationFormGroup
              field="confirm_password"
              validations={{ equalsField: 'password' }}
              validationErrors={{ equalsField: 'Must match password' }}
              type="password"
              required={false}
              {...sharedProps}
            />
            {/* <div className="flex-100">
              <h3>Address Details</h3>
            </div>
            <RegistrationFormGroup field="street" minLength="2" flex="70" {...sharedProps} />
            <RegistrationFormGroup
              field="number"
              minLength="1"
              flex="25"
              offset="5"
              {...sharedProps}
            />
            <RegistrationFormGroup field="zip_code" minLength="4" flex="30" {...sharedProps} />
            <RegistrationFormGroup
              field="city"
              minLength="2"
              flex="30"
              offset="5"
              {...sharedProps}
            />
            <RegistrationFormGroup
              field="country"
              minLength="3"
              flex="30"
              offset="5"
              {...sharedProps}
            />
          </div>
          <div className="offset-10 flex-45 layout-row layout-wrap">
            <div className="flex-100">
              <h3>Company Details</h3>
            </div>
            <RegistrationFormGroup field="company_name" minLength="4" {...sharedProps} />
            <RegistrationFormGroup field="VAT_number" minLength="5" {...sharedProps} />
            <div className={styles.pusher} />
            <RegistrationFormGroup field="first_name" minLength="2" {...sharedProps} />
            <RegistrationFormGroup field="last_name" minLength="2" {...sharedProps} />
            <RegistrationFormGroup field="phone" minLength="8" {...sharedProps} /> */}
          </div>
        </div>
        <TermsAndConditionsSummary
          theme={theme}
          tenant={tenant}
          handleChange={(e, x) => this.handleChangeTermsAndConditionsAccepted(e, x)}
          accepted={this.state.termsAndConditionsAccepted}
          shakeClass={this.state.shakeClass}
          goToTermsAndConditions={() => authenticationDispatch.goTo('/terms_and_conditions', true)}
          goToImcTermsAndConditions={() => window.open('https://www.itsmycargo.com/en/terms', '_blank')}
        />
        <div className={`${styles.form_group_submit_btn} layout-row layout-align-center`}>
          <RoundButton
            text="Register new account"
            theme={theme}
            active={this.allAccepted()}
            disabled={!this.allAccepted()}
          />
          <div className={styles.spinner}>{ registering && <LoadingSpinner /> }</div>
        </div>
      </Formsy>
    )
  }
}

RegistrationPage.propTypes = {
  tenant: PropTypes.tenant,
  registrationAttempt: PropTypes.bool,
  // eslint-disable-next-line react/forbid-prop-types
  req: PropTypes.any,
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any,
  theme: PropTypes.theme,
  registering: PropTypes.bool,
  authenticationDispatch: PropTypes.objectOf(PropTypes.any).isRequired
}

RegistrationPage.defaultProps = {
  tenant: null,
  registrationAttempt: false,
  user: null,
  theme: null,
  req: null,
  registering: false
}

function mapStateToProps (state) {
  const { registering, registrationAttempt, req } = state.authentication
  return {
    registering,
    registrationAttempt,
    req
  }
}

function mapDispatchToProps (dispatch) {
  return {
    authenticationDispatch: bindActionCreators(authenticationActions, dispatch)
  }
}

const connectedRegistrationPage = connect(mapStateToProps, mapDispatchToProps)(RegistrationPage)
export { connectedRegistrationPage as RegistrationPage }
export default connectedRegistrationPage
