import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import FormsyInput from '../../FormsyInput/FormsyInput'
import { RoundButton } from '../../RoundButton/RoundButton'
import styles from './AdminSettings.scss'
import CircleCompletion from '../../CircleCompletion/CircleCompletion'
import { withNamespaces } from 'react-i18next'
import { capitalize } from '../../../helpers'

class AdminEmailForm extends Component {
  static mapInputs (inputs) {
    return Object.keys(inputs).reduce((emails, inputName) => {
      const [key, subKey] = inputName.split('-')
      const email = inputs[inputName]

      return { ...emails, [key]: { ...emails[key], [subKey]: email } }
    }, {})
  }

  constructor (props) {
    super(props)

    this.state = {
      changedEmailAttempt: false,
      canSubmit: false
    }

    this.saveEmails = this.saveEmails.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.disableButton = this.disableButton.bind(this)
    this.enableButton = this.enableButton.bind(this)
  }

  componentWillReceiveProps (nextProps) {
    const { tenantDispatch } = this.props

    if (nextProps.tenant.savedEmailSuccess) {
      setTimeout(() => {
        tenantDispatch.updateReduxStore({ savedEmailSuccess: false })
      }, 2000)
    }
  }

  saveEmails (newEmails) {
    const { tenantDispatch, tenant } = this.props
    tenantDispatch.updateEmails(newEmails, tenant)
  }

  handleInvalidSubmit () {
    if (!this.state.changedEmailAttempt) this.setState({ changedEmailAttempt: true })
  }

  disableButton () {
    this.setState({ canSubmit: false })
  }

  enableButton () {
    this.setState({ canSubmit: true })
  }

  render () {
    const { t, tenant, theme } = this.props
    const emails = tenant.emails

    const emailKeys = Object.keys(tenant.emails)

    const emailInputs = emailKeys.map(key => (
      <div>
        <h3>{capitalize(key)} {t('user:emails')}:</h3>

        <div className={`${styles.email_settings} flex-100 layout-row layout-row layout-align-center-start`}>
          <div className={`flex-100 layout-align-center-center padding_right layout-gt-sm-row layout-column ${styles.input_box} input`}>
            {Object.entries(emails[key]).map(([subKey, email]) => (
              <div>
                <div className={`${styles.email_header}`}>
                  <p>{capitalize(subKey)}</p>
                </div>
                <FormsyInput
                  className={styles.input}
                  type="text"
                  name={`${key}-${subKey}`}
                  placeholder={capitalize(subKey)}
                  value={email}
                  errorMessageStyles={{
                    position: 'absolute',
                    left: '16px',
                    fontSize: '12px',
                    bottom: '5px'
                  }}
                  validations={{
                    minLength: 2,
                    matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
                  }}
                  submitAttempted={this.state.changedEmailAttempt}
                  validationErrors={{
                    isDefaultRequiredValue: t('errors:notBlank'),
                    minLength: t('errors:twoChars'),
                    matchRegexp: t('errors:invalidEmail')
                  }}
                  required
                />
              </div>
            ))
            }
          </div>
        </div>
      </div>

    ))

    return (
      <div className="flex-100 layout-row layout-align-space-between-center">
        <Formsy
          onValidSubmit={this.saveEmails}
          onInvalidSubmit={this.handleInvalidSubmit}
          mapping={AdminEmailForm.mapInputs}
          className="flex-100 layout-column layout-gt-md-row layout-align-start-center"
          onValid={this.enableButton}
          onInvalid={this.disableButton}
        >
          <div className="flex-100 flex-gt-md-75 layout-row layout-wrap layout-align-start-center">
            {emailInputs}
          </div>
          <div className="flex-100 flex-gt-md-25 layout-column layout-align-end-center padding_right padding_top" >
            <CircleCompletion
              icon="fa fa-check"
              iconColor={theme.colors.primary || 'green'}
              animated={tenant.savedEmailSuccess}
              optionalText={t('admin:accountEmailsUpdated')}
            />
            <RoundButton
              theme={theme}
              active={this.state.canSubmit}
              disabled={!this.state.canSubmit}
              size="medium"
              text={t('common:save')}
            />
          </div>
        </Formsy>
      </div>
    )
  }
}

AdminEmailForm.propTypes = {
  theme: PropTypes.theme,
  tenant: PropTypes.tenant.isRequired,
  tenantDispatch: PropTypes.shape({
    updateEmails: PropTypes.func,
    savedEmailSuccess: PropTypes.func
  }).isRequired,
  savedEmailSuccess: PropTypes.bool,
  t: PropTypes.func.isRequired
}

AdminEmailForm.defaultProps = {
  theme: {},
  savedEmailSuccess: false
}
export default withNamespaces(['admin', 'common', 'user', 'errors'])(AdminEmailForm)
