import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import Formsy from 'formsy-react'
import { authenticationActions } from '../../actions'
import { RoundButton } from '../../components/RoundButton/RoundButton'
import { LoadingSpinner } from '../../components/LoadingSpinner/LoadingSpinner'
import RegistrationFormGroup from './components/RegistrationFormGroup'
import TermsAndConditionsSummary from './components/TermsAndConditionsSummary'
import styles from './RegistrationPage.scss'

class RegistrationPage extends React.PureComponent {
  static mapInputs (inputs) {
    const model = { }
    Object.keys(inputs).forEach((inputName) => {
      model[inputName] = inputs[inputName]
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
              field="company_name"
              minLength="2"
              {...sharedProps}
            />
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
