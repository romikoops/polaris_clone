import React from 'react'
import Formsy from 'formsy-react'
import PropTypes from '../../prop-types'
import { LoadingSpinner } from '../LoadingSpinner/LoadingSpinner'
import { RoundButton } from '../RoundButton/RoundButton'
import styles from './ResetPasswordForm.scss'
import FormsyInput from '../FormsyInput/FormsyInput'
import getApiHost from '../../constants/api.constants'
import { queryStringToObj } from '../../helpers'
import Header from '../Header/Header'

const { fetch } = window

function buildHeaders (data) {
  const headers = { 'Content-Type': 'application/json' }
  const headerKeys = ['access-token', 'client', 'uid']
  Object.keys(data).forEach((k) => { if (headerKeys.includes(k)) headers[k] = data[k] })
  return headers
}

export default class ResetPasswordForm extends React.PureComponent {
  constructor (props) {
    super(props)
    this.state = { focus: {}, settingPassword: false }
  }
  handleSubmit (model) {
    const queryString = this.props.location.search.substring(1)

    if (queryString === '') {
      window.alert((
        'You attempted to submit an invalid reset password request. ' +
        'If you wish to reset your password, ' +
        'please follow a valid link sent to your email.'
      ))
      return
    }

    const queryStringData = queryStringToObj(queryString)

    this.setState({ settingPassword: true })

    fetch(`${getApiHost()}/auth/password`, {
      method: 'PUT',
      headers: buildHeaders(queryStringData),
      body: JSON.stringify(model)
    }).then((promise) => {
      promise.json().then((response) => {
        // TBD - render some animation instead of reloading the page
        window.location.replace('/')
      })
    })
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
    const { theme, user } = this.props
    const { settingPassword } = this.state
    const focusStyles = {
      borderColor: theme && theme.colors ? theme.colors.primary : 'black',
      borderWidth: '1.5px',
      borderRadius: '2px',
      margin: '-1px 0 29px 0'
    }
    return (
      <div className="flex-100 layout-row layout-wrap">
        <Header user={user} theme={theme} noMessages />

        <div className="flex-100 layout-row layout-align-center hundred">
          <div className="content_width layout-row layout-align-center-center">
            <Formsy
              className={styles.reset_password_form}
              name="form"
              onValidSubmit={model => this.handleSubmit(model)}
              onInvalidSubmit={model => this.handleInvalidSubmit(model)}
            >
              <div className="form-group">
                <label htmlFor="password">Password</label>
                <FormsyInput
                  type="password"
                  className={styles.form_control}
                  onFocus={e => this.handleFocus(e)}
                  onBlur={e => this.handleFocus(e)}
                  name="password"
                  id="password"
                  submitAttempted={this.state.submitAttempted}
                  validations={{ minLength: 8 }}
                  validationErrors={{
                    minLength: 'Min. 8 characters',
                    isDefaultRequiredValue: 'Must not be blank'
                  }}
                  errorMessageStyles={{
                    fontSize: '12px',
                    bottom: '-19px'
                  }}
                  required
                />

                <hr style={this.state.focus.password ? focusStyles : {}} />
              </div>

              <div className="form-group">
                <label htmlFor="password_confirmation">Confirm Password</label>
                <FormsyInput
                  type="password"
                  className={styles.form_control}
                  onFocus={e => this.handleFocus(e)}
                  onBlur={e => this.handleFocus(e)}
                  name="password_confirmation"
                  id="password_confirmation"
                  submitAttempted={this.state.submitAttempted}
                  validations={{ equalsField: 'password' }}
                  validationErrors={{ equalsField: 'Must match password' }}
                  errorMessageStyles={{
                    fontSize: '12px',
                    bottom: '-19px'
                  }}
                />

                <hr style={this.state.focus.password_confirmation ? focusStyles : {}} />
              </div>

              <p style={{ fontSize: '13px', textAlign: 'justify', width: '271px' }}>
                By clicking {'\'Set Password\''}, you will reset the password of your ItsMyCargo
                account.
              </p>
              <div className={`${styles.form_group_submit_btn} layout-row layout-align-center-center`}>
                <RoundButton text="Set Password" theme={theme} size="small" active />
                <div className={styles.spinner}>{settingPassword && <LoadingSpinner />}</div>
              </div>
            </Formsy>
          </div>
        </div>
      </div>
    )
  }
}

ResetPasswordForm.propTypes = {
  user: PropTypes.user,
  theme: PropTypes.theme,
  location: PropTypes.objectOf(PropTypes.any).isRequired
}

ResetPasswordForm.defaultProps = {
  user: null,
  theme: null
}
