import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import FormsyInput from '../../FormsyInput/FormsyInput'
import { RoundButton } from '../../RoundButton/RoundButton'
import { withNamespaces } from 'react-i18next'
import { capitalize } from '../../../helpers'


class AdminEmailForm extends Component {
  constructor (props) {
    super(props)
    // this.saveEmail = this.saveEmail.bind(this)
    this.saveEmails = this.saveEmails.bind(this)
  }

  saveEmails () {
    const { adminDispatch, tenant } = this.props
    adminDispatch.updateEmails(tenant)
  }

  render () {
    const { t, tenant, theme } = this.props
    const emails = tenant.data.emails

    const emailKeys = Object.keys(tenant.data.emails)

    const emailInputs = emailKeys.map(key => (
      <div>
        <p>{capitalize(key)}</p>

        <div className="flex-100 layout-row layout-row layout-align-center-start">
          <div className="flex-100 layout-row layout-align-start-center input_box">
            {Object.entries(emails[key]).map(subKey => (
              <FormsyInput
                type="text"
                name={capitalize(subKey[0])}
                placeholder={capitalize(subKey[0])}
                value={subKey[1]}
              />
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
          className="flex-100 layout-row layout-align-start-center"
        >
          <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
            <div className="flex-100 layout-row layout-align-start-center">
              <h2 className="flex-none sup_l">
                {t('admin:updateShopEmails')}
              </h2>
            </div>
          </div>
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
  adminDispatch: PropTypes.shape({
    updateEmails: PropTypes.func
  }).isRequired,
  t: PropTypes.func.isRequired
}

AdminEmailForm.defaultProps = {
  theme: {}
}
export default withNamespaces(['admin', 'common'])(AdminEmailForm)
