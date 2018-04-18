import React from 'react'
import { connect } from 'react-redux'
import Formsy from 'formsy-react'
import PropTypes from '../../prop-types'
import { authenticationActions } from '../../actions'
import { RoundButton } from '../../components/RoundButton/RoundButton'
import { Alert } from '../../components/Alert/Alert'
import { LoadingSpinner } from '../../components/LoadingSpinner/LoadingSpinner'
import styles from './LoginPage.scss'
import FormsyInput from '../../components/FormsyInput/FormsyInput'

class LoginPage extends React.Component {
  constructor (props) {
    super(props)

    this.state = {
      submitAttempted: false,
      focus: {},
      alertVisible: false
    }

    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.handleFocus = this.handleFocus.bind(this)
    this.hideAlert = this.hideAlert.bind(this)
  }
  componentWillMount () {
    if (this.props.loginAttempt && !this.state.alertVisible) {
      this.setState({ alertVisible: true })
    }
    console.log('MOUNTED')
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.loginAttempt && !this.state.alertVisible) {
      this.setState({ alertVisible: true })
    }
  }

  hideAlert () {
    this.setState({ alertVisible: false })
  }

  handleSubmit (model) {
    const { email, password } = model
    const { dispatch, req, noRedirect } = this.props
    dispatch(authenticationActions.login({
      email,
      password,
      req,
      noRedirect
    }))
  }
  handleInvalidSubmit () {
    if (!this.state.submitAttempted) this.setState({ submitAttempted: true })
  }

  handleFocus (e) {
    this.setState({
      focus: {
        ...this.state.focus,
        [e.target.name]: e.type === 'focus'
      }
    })
  }

  render () {
    const { loggingIn, theme } = this.props
    const focusStyles = {
      borderColor: theme && theme.colors ? theme.colors.primary : 'black',
      borderWidth: '1.5px',
      borderRadius: '2px',
      margin: '-1px 0 29px 0'
    }
    const alert = this.state.alertVisible ? (
      <Alert
        message={{ type: 'error', text: 'Wrong email or password' }}
        onClose={this.hideAlert}
        timeout={10000}
      />
    ) : (
      ''
    )
    const formPosition =
      navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true
        ? `${styles.login_form} ${styles.login_ie_11}`
        : styles.login_form
    return (
      <Formsy
        className={formPosition}
        name="form"
        onValidSubmit={this.handleSubmit}
        onInvalidSubmit={this.handleInvalidSubmit}
      >
        {alert}
        <div className="form-group">
          <label htmlFor="email">Email</label>
          <FormsyInput
            type="text"
            className={styles.form_control}
            onFocus={this.handleFocus}
            onBlur={this.handleFocus}
            name="email"
            placeholder="enter your email"
            submitAttempted={this.state.submitAttempted}
            validationErrors={{ isDefaultRequiredValue: 'Must not be blank' }}
            required
          />
          <hr style={this.state.focus.email ? focusStyles : {}} />
        </div>
        <div className="form-group">
          <label htmlFor="password">Password</label>
          <FormsyInput
            type="password"
            className={styles.form_control}
            name="password"
            placeholder="enter your password"
            submitAttempted={this.state.submitAttempted}
            validationErrors={{ isDefaultRequiredValue: 'Must not be blank' }}
            required
          />
          <hr style={this.state.focus.password ? focusStyles : {}} />
          <a href="#" className={styles.forget_password_link}>
            forgot password?
          </a>
        </div>
        <div className={`form-group ${styles.form_group_submit_btn}`}>
          <RoundButton text="Sign In" theme={theme} active />
          <div className={styles.spinner}>{loggingIn && <LoadingSpinner />}</div>
        </div>
      </Formsy>
    )
  }
}

function mapStateToProps (state) {
  const { loggingIn, loginAttempt, user } = state.authentication
  return {
    loggingIn,
    loginAttempt,
    user
  }
}

LoginPage.propTypes = {
  dispatch: PropTypes.func.isRequired,
  loggingIn: PropTypes.bool,
  theme: PropTypes.theme,
  loginAttempt: PropTypes.bool,
  noRedirect: PropTypes.bool,

  // eslint-disable-next-line react/forbid-prop-types
  req: PropTypes.object
}

LoginPage.defaultProps = {
  loggingIn: false,
  theme: null,
  loginAttempt: false,
  noRedirect: false,
  req: null
}

const connectedLoginPage = connect(mapStateToProps)(LoginPage)
export { connectedLoginPage as LoginPage }

export default connectedLoginPage
