import React from 'react'
import { connect } from 'react-redux'
import Formsy from 'formsy-react'
import PropTypes from '../../prop-types'
import { authenticationActions } from '../../actions'
import { RoundButton } from '../../components/RoundButton/RoundButton'
import { Alert } from '../../components/Alert/Alert'
import { LoadingSpinner } from '../../components/LoadingSpinner/LoadingSpinner'
import { humanizeSnakeCase } from '../../helpers'
import styles from './RegistrationPage.scss'
import FormsyInput from '../../components/FormsyInput/FormsyInput'

class RegistrationPage extends React.Component {
  static mergeMinLengthValidations (minLength, validations, validationErrors) {
    const returnObj = {}
    returnObj.validations = Object.assign(minLength ? { minLength } : {}, validations || {})

    const minLengthErrors = {
      isDefaultRequiredValue: `Min. ${minLength} characters`,
      minLength: `Min. ${minLength} characters`
    }
    returnObj.validationErrors = Object.assign(
      minLength ? minLengthErrors : {},
      validationErrors || {}
    )
    return returnObj
  }
  static mapInputs (inputs) {
    const locationInputs = ['street', 'number', 'zip_code', 'city', 'country']
    const model = { location: {} }
    Object.keys(inputs).forEach((inputName) => {
      if (inputName === 'number') {
        model.location.street_number = inputs.number
      } else if (locationInputs.includes(inputName)) {
        model.location[inputName] = inputs[inputName]
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
      alertVisible: false
    }

    this.handleFocus = this.handleFocus.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.hideAlert = this.hideAlert.bind(this)
    this.generateFormGroup = this.generateFormGroup.bind(this)
  }

  componentWillMount () {
    if (this.props.registrationAttempt && !this.state.alertVisible) {
      this.setState({ alertVisible: true })
    }
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.registrationAttempt && !this.state.alertVisible) {
      this.setState({ alertVisible: true })
    }
  }

  hideAlert () {
    this.setState({ alertVisible: false })
  }

  handleFocus (e) {
    this.setState({
      focus: {
        ...this.state.focus,
        [e.target.name]: e.type === 'focus'
      }
    })
  }

  handleSubmit (model) {
    const user = Object.assign({}, model)
    user.tenant_id = this.props.tenant.data.id
    user.guest = false

    const { dispatch, req } = this.props
    if (req) {
      dispatch(authenticationActions.updateUser(this.props.user, user, req))
    } else {
      dispatch(authenticationActions.register(user))
    }
  }

  handleInvalidSubmit () {
    if (!this.state.submitAttempted) this.setState({ submitAttempted: true })
  }

  generateFormGroup (args) {
    const {
      field, flex, offset, minLength, type, required
    } = args
    const { theme } = this.props
    const focusStyles = {
      borderColor: theme && theme.colors ? theme.colors.primary : 'black',
      borderWidth: '1.5px',
      borderRadius: '2px',
      margin: '-1px 0 29px 0'
    }

    let { validations, validationErrors } = args
    if (minLength) {
      ({ validations, validationErrors } =
        RegistrationPage.mergeMinLengthValidations(minLength, validations, validationErrors))
    }

    return (
      <div className={`flex-${flex || '100'} offset-${offset || 0}`}>
        <label htmlFor={field}>{humanizeSnakeCase(field)}</label>
        <FormsyInput
          type={type || 'text'}
          className={styles.form_control}
          onFocus={this.handleFocus}
          onBlur={this.handleFocus}
          name={field}
          id={field}
          submitAttempted={this.state.submitAttempted}
          validations={validations}
          validationErrors={validationErrors}
          errorMessageStyles={{
            fontSize: '12px',
            bottom: '-19px'
          }}
          required={required == null ? true : required}
        />
        <hr style={this.state.focus[field] ? focusStyles : {}} />
      </div>
    )
  }

  render () {
    const { registering, theme } = this.props
    const alert = this.state.alertVisible ? (
      <Alert
        message={{ type: 'error', text: 'Email has already been taken' }}
        onClose={this.hideAlert}
        timeout={10000}
      />
    ) : (
      ''
    )
    return (
      <Formsy
        className={styles.registration_form}
        name="form"
        onValidSubmit={this.handleSubmit}
        onInvalidSubmit={this.handleInvalidSubmit}
        mapping={RegistrationPage.mapInputs}
      >
        {alert}
        <div className="flex-100 layout-row layout-wrap">
          <div className="flex-45 layout-row layout-wrap">
            <div className="flex-100">
              <h3>Account Details</h3>
            </div>
            {
              this.generateFormGroup({
                field: 'email',
                minLength: 2,
                validations: { matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i },
                validationErrors: { matchRegexp: 'Invalid email' }
              })
            }
            { this.generateFormGroup({ field: 'password', minLength: 8, type: 'password' }) }
            {
              this.generateFormGroup({
                field: 'confirm_password',
                validations: { equalsField: 'password' },
                validationErrors: {
                  equalsField: 'Must match password'
                },
                type: 'password',
                required: false
              })
            }
            <div className="flex-100">
              <h3>Address Details</h3>
            </div>
            { this.generateFormGroup({ field: 'street', minLength: 2, flex: 70 }) }
            {
              this.generateFormGroup({
                field: 'number', minLength: 1, flex: 25, offset: 5
              })
            }
            { this.generateFormGroup({ field: 'zip_code', minLength: 4, flex: 30 }) }
            {
              this.generateFormGroup({
                field: 'city', minLength: 2, flex: 30, offset: 5
              })
            }
            {
              this.generateFormGroup({
                field: 'country', minLength: 3, flex: 30, offset: 5
              })
            }
          </div>
          <div className="offset-10 flex-45 layout-row layout-wrap">
            <div className="flex-100">
              <h3>Basic Details</h3>
            </div>
            { this.generateFormGroup({ field: 'company_name', minLength: 8 }) }
            { this.generateFormGroup({ field: 'VAT_number', minLength: 5 }) }
            <div className={styles.pusher} />
            { this.generateFormGroup({ field: 'first_name', minLength: 2 }) }
            { this.generateFormGroup({ field: 'last_name', minLength: 2 }) }
            { this.generateFormGroup({ field: 'phone', minLength: 8 }) }
          </div>
        </div>
        <div className={`${styles.form_group_submit_btn} layout-row layout-align-center`}>
          <RoundButton text="Register new account" theme={theme} active />
          <div className={styles.spinner}>{ registering && <LoadingSpinner /> }</div>
        </div>
      </Formsy>
    )
  }
}

RegistrationPage.propTypes = {
  tenant: PropTypes.tenant,
  registrationAttempt: PropTypes.bool,
  dispatch: PropTypes.func.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  req: PropTypes.any,
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any,
  theme: PropTypes.theme,
  registering: PropTypes.bool
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
  const { registering, registrationAttempt } = state.authentication
  return {
    registering,
    registrationAttempt
  }
}

const connectedRegistrationPage = connect(mapStateToProps)(RegistrationPage)
export { connectedRegistrationPage as RegistrationPage }
export default connectedRegistrationPage
