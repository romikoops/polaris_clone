import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../prop-types'
import GenericError from '../../../components/ErrorHandling/Generic'
import styles from './AdminSettings.scss'
import AdminEmailForm from './AdminEmailForm'

class AdminSettings extends PureComponent {
  render () {
    const {
      t,
      theme,
      tenant,
      tenantDispatch
    } = this.props

    return (
      <GenericError theme={theme}>
        <div className={`layout-row flex-100 layout-wrap layout-align-start-center extra_padding ${styles.container}`}>
          <h3>{t('account:accountSettings')}</h3>
          <AdminEmailForm
            theme={theme}
            tenant={tenant}
            tenantDispatch={tenantDispatch}
          />
        </div>
      </GenericError>
    )
  }
}

AdminSettings.propTypes = {
  tenant: PropTypes.tenant.isRequired,
  tenantDispatch: PropTypes.shape({
    updateEmails: PropTypes.func
  }).isRequired,
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired
}

AdminSettings.defaultProps = {
  theme: null
}
export default withNamespaces('account')(AdminSettings)
