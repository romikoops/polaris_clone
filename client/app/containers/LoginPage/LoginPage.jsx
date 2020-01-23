import React from 'react'
import { connect } from 'react-redux'
import Formsy from 'formsy-react'
import { get } from 'lodash'
import { authenticationActions } from '../../actions'
import { RoundButton } from '../../components/RoundButton/RoundButton'
import { LoadingSpinner } from '../../components/LoadingSpinner/LoadingSpinner'
import styles from './LoginPage.scss'
import FormsyInput from '../../components/FormsyInput/FormsyInput'
import ForgotPassword from './ForgotPassword'

class LoginPage extends React.Component {
  constructor (props) {
    super(props)

    this.state = {
      submitAttempted: false,
      focus: {}
    }

    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.handleFocus = this.handleFocus.bind(this)
  }

  handleSubmit (model) {
    const { email, password } = model
    const {
      dispatch, req, noRedirect, redirectUrl
    } = this.props
    dispatch(authenticationActions.login({
      email,
      password,
      req,
      noRedirect,
      redirectUrl
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

  renderForgotPassword () {
    this.setState({ forgotPassword: true })
  }

  render () {
    const { loggingIn, theme, scope } = this.props
    const focusStyles = {
      borderColor: theme && theme.colors ? theme.colors.primary : 'black',
      borderWidth: '1.5px',
      borderRadius: '2px',
      margin: '-1px 0 29px 0'
    }
    const allowForgotPassword = !get(scope, 'user_restrictions.profile.password')

    if (this.state.forgotPassword) {
      return <ForgotPassword focusStyles={focusStyles} theme={theme} />
    }

    const ie11Positioning =
      navigator.userAgent.includes('MSIE') || document.documentMode ? styles.login_ie_11 : ''

    return (
      <Formsy
        className={`${styles.login_form} ${ie11Positioning}`}
        name="form"
        onValidSubmit={this.handleSubmit}
        onInvalidSubmit={this.handleInvalidSubmit}
      >
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
          { allowForgotPassword && (
            <a onClick={() => this.renderForgotPassword()} className={styles.forget_password_link}>
            forgot password?
            </a>
          )
          }
        </div>
        <div className={`form-group ${styles.form_group_submit_btn}`}>
          <RoundButton classNames="ccb_signin" text="Sign In" theme={theme} active />
          <div className={styles.spinner}>{loggingIn && <LoadingSpinner />}</div>
        </div>
      </Formsy>
    )
  }
}

function mapStateToProps (state) {
  const { authentication, app } = state
  const {
    loggingIn, loginAttempt, user, noRedirect, req, redirectUrl
  } = authentication
  const { scope } = app.tenant

  return {
    loggingIn,
    loginAttempt,
    user,
    noRedirect,
    req,
    redirectUrl,
    scope
  }
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
