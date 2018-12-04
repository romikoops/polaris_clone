import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import FileUploader from '../../components/FileUploader/FileUploader'

export function SuperAdmin ({ t, theme }) {
  const upUrl = '/super_admins/new_demo'

  return (
    <div className="flex-100 layout-row layout-align-space-between-center">
      <p className="flex-none">{t('admin:uploadDemoTenantObject')}</p>
      <FileUploader theme={theme} url={upUrl} type="xlsx" text={t('admin:tenant')} />
    </div>
  )
}

SuperAdmin.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme
}

SuperAdmin.defaultProps = {
  theme: null
}

export default withNamespaces('admin')(SuperAdmin)
