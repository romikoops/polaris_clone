/* eslint-disable jsx-a11y/label-has-associated-control */
import React from 'react'
import { connect } from 'react-redux'
import Formsy from 'formsy-react'
import { get } from 'lodash'
import { withNamespaces } from 'react-i18next'
import { authenticationActions } from '../../actions'
import { RoundButton } from '../../components/RoundButton/RoundButton'
import { LoadingSpinner } from '../../components/LoadingSpinner/LoadingSpinner'
import styles from './LoginPage.scss'
import FormsyInput from '../../components/FormsyInput/FormsyInput'
import ForgotPassword from './ForgotPassword'

class LoginPage extends React.Component {
  static redirectToSamlLogin () {
    window.location.href = '/saml/init'
  }

  constructor (props) {
    super(props)

    this.state = {
      submitAttempted: false,
      focus: {},
      showLoginForm: !props.authMethods.includes('saml')
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

  toggleShowLoginForm () {
    this.setState((prevState) => ({ showLoginForm: !prevState.showLoginForm }))
  }

  renderForgotPassword () {
    this.setState({ forgotPassword: true })
  }

  render () {
    const { loggingIn, theme, scope, authMethods, t } = this.props
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
    const hasSamlLogin = authMethods.includes('saml')
    const { focus, submitAttempted, showLoginForm } = this.state
    const { email, password } = focus

    return (
      <div>
        {hasSamlLogin && (
          <div className={`form-group ${showLoginForm ? '' : styles.samlPadding}`}>
            <RoundButton
              handleNext={() => LoginPage.redirectToSamlLogin()}
              classNames="ccb_saml_signin"
              text={t('login:samlText', { text: scope.saml_text })}
              theme={theme}
              active
            />
            { showLoginForm && <hr className={styles.saml_border} /> }
          </div>
        )}
        <Formsy
          className={`${styles.login_form} ${ie11Positioning}`}
          name="form"
          onValidSubmit={this.handleSubmit}
          onInvalidSubmit={this.handleInvalidSubmit}
        >
          <div className={`form-group ${styles.form} ${showLoginForm ? '' : styles.hideForm}`}>
            <label htmlFor="email">{t('login:email')}</label>
            <FormsyInput
              type="text"
              className={styles.form_control}
              onFocus={this.handleFocus}
              onBlur={this.handleFocus}
              name="email"
              placeholder={t('login:enterEmail')}
              submitAttempted={submitAttempted}
              validationErrors={{ isDefaultRequiredValue: t('login:mustNotBeBlank') }}
              required
            />
            <hr style={email ? focusStyles : {}} />
          </div>
          <div className={`form-group ${styles.form} ${showLoginForm ? '' : styles.hideForm}`}>
            <label htmlFor="password">{t('login:password')}</label>
            <FormsyInput
              type="password"
              className={styles.form_control}
              name="password"
              placeholder={t('login:enterPassword')}
              submitAttempted={submitAttempted}
              validationErrors={{ isDefaultRequiredValue: t('login:mustNotBeBlank') }}
              required
            />
            <hr style={password ? focusStyles : {}} />
            {allowForgotPassword && (
              <a
                onClick={() => this.renderForgotPassword()}
                className={`forgotPassword ${styles.forget_password_link}`}
              >
                {t('login:forgotPassword')}
              </a>
            )}
          </div>
          <div
            className={`form-group ${styles.form_group_submit_btn}
            ${styles.form} ${showLoginForm ? '' : styles.hideForm}`}
          >
            <RoundButton classNames="ccb_signin" text={t('login:signIn')} theme={theme} active />
            <div className={styles.spinner}>{loggingIn && <LoadingSpinner />}</div>
          </div>
        </Formsy>
        <div>
          {(hasSamlLogin && !showLoginForm) && (
            <a onClick={() => this.toggleShowLoginForm()} className={`showLogin ${styles.admin_login_text}`}>
              {t('login:emailLogin')}
            </a>
          )}
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { authentication, app } = state
  const {
    loggingIn, loginAttempt, user, noRedirect, req, redirectUrl
  } = authentication
  const { scope, auth_methods: authMethods } = app.tenant

  return {
    loggingIn,
    loginAttempt,
    user,
    noRedirect,
    req,
    redirectUrl,
    scope,
    authMethods
  }
}

LoginPage.defaultProps = {
  loggingIn: false,
  theme: null,
  loginAttempt: false,
  noRedirect: false,
  req: null,
  authMethods: []
}

const connectedLoginPage = connect(mapStateToProps)(LoginPage)
const translatedLoginPage = withNamespaces(['login'])(connectedLoginPage)
export { translatedLoginPage as LoginPage }

export default translatedLoginPage
