import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import FormsyInput from '../../FormsyInput/FormsyInput'
import { RoundButton } from '../../RoundButton/RoundButton'
import styles from './AdminSettings.scss'
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
    this.saveEmails = this.saveEmails.bind(this)
  }

  saveEmails (newEmails) {
    const { tenantDispatch, tenant } = this.props
    tenantDispatch.updateEmails(newEmails, tenant)
  }

  render () {
    const { t, tenant, theme } = this.props
    const emails = tenant.data.emails

    const emailKeys = Object.keys(tenant.data.emails)
    
    const typeStyle = {
      textAlign: 'center',
      fontWeight: 'bold'
    }

    const emailInputs = emailKeys.map(key => (
      <div>
        <h3>{capitalize(key)} {t('user:emails')}:</h3>

        <div className={`${styles.email_settings} flex-100 layout-row layout-row layout-align-center-start`}>
          <div className="flex-100 layout-row layout-align-center-center input_box">
            {Object.entries(emails[key]).map(([subKey, email]) => (
              <div>
                <div style={typeStyle}>
                  <p>{capitalize(subKey)}</p>
                </div>
                <FormsyInput
                  type="text"
                  name={`${key}-${subKey}`}
                  placeholder={capitalize(subKey)}
                  value={email}
                />
              </div>
            ))
            }
          </div>
        </div>
      </div>

    ))

    return (
      <div className="flex-100 layout-row layout-align-start-center">
        <Formsy
          onValidSubmit={this.saveEmails}
          mapping={AdminEmailForm.mapInputs}
          className="flex-100 layout-row layout-align-start-center"
        >
          <div className="flex-100 layout-row layout-row layout-wrap layout-align-center-start">
            {emailInputs}
          </div>
          <div className="flex-33 layout-row layout-align-center-center" >
            <RoundButton
              theme={theme}
              size="small"
              text={t('common:save')}
              iconClass="fa-plus-square-o"
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
    updateEmails: PropTypes.func
  }).isRequired,
  t: PropTypes.func.isRequired
}

AdminEmailForm.defaultProps = {
  theme: {}
}
export default withNamespaces(['admin', 'common', 'user'])(AdminEmailForm)
