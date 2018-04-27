import React from 'react'
import Formsy from 'formsy-react'
import PropTypes from '../../../prop-types'
// import { authenticationActions } from '../../actions'
import { RoundButton } from '../../../components/RoundButton/RoundButton'
import styles from './ForgotPassword.scss'
import FormsyInput from '../../../components/FormsyInput/FormsyInput'

export default class ForgotPassword extends React.PureComponent {
  constructor (props) {
    super(props)
    this.state = { focus: {} }
  }
  handleSubmit (model) {
    console.log(this.props)
    console.log(model)

    // TBD - render some animation instead of reloading the page
    window.location.replace('/')
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
    const { focusStyles, theme } = this.props
    return (
      <Formsy
        className={styles.forgot_password_form}
        name="form"
        onValidSubmit={this.handleSubmit}
        onInvalidSubmit={this.handleInvalidSubmit}
      >
        <div className="form-group">
          <label htmlFor="email">Email</label>
          <FormsyInput
            type="text"
            className={styles.form_control}
            onFocus={e => this.handleFocus(e)}
            onBlur={e => this.handleFocus(e)}
            name="email"
            placeholder="enter your email"
            submitAttempted={this.state.submitAttempted}
            validationErrors={{ isDefaultRequiredValue: 'Must not be blank' }}
            required
          />
          <hr style={this.state.focus.email ? focusStyles : {}} />
        </div>
        <p style={{ fontSize: '13px', textAlign: 'justify', width: '271px' }}>
          By clicking {'\'Send\''}, a link will be sent to your
          email address, in order to reset your password.
        </p>
        <div className="layout-row layout-align-center-center">
          <RoundButton text="Send" theme={theme} size="small" active />
        </div>
      </Formsy>
    )
  }
}

ForgotPassword.propTypes = {
  theme: PropTypes.theme,
  focusStyles: PropTypes.objectOf(PropTypes.any)
}

ForgotPassword.defaultProps = {
  theme: null,
  focusStyles: {}
}
