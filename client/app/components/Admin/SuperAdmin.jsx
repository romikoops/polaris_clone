import React from 'react'
import PropTypes from '../../prop-types'
import FileUploader from '../../components/FileUploader/FileUploader'

export function SuperAdmin ({ theme }) {
  const upUrl = '/super_admins/new_demo'

  return (
    <div className="flex-100 layout-row layout-align-space-between-center">
      <p className="flex-none">Upload Demo Tenant Object</p>
      <FileUploader theme={theme} url={upUrl} type="xlsx" text="Tenant" />
    </div>
  )
}

SuperAdmin.propTypes = {
  theme: PropTypes.theme
}

SuperAdmin.defaultProps = {
  theme: null
}

export default SuperAdmin
