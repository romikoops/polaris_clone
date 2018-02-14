import React from 'react'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { AdminSearchableHubs } from './AdminSearchables'
import FileUploader from '../../components/FileUploader/FileUploader'

export function AdminHubsIndex ({
  theme, hubs, viewHub, adminDispatch
}) {
  const hubUrl = '/admin/hubs/process_csv'
  return (
    <div className="flex-100 layout-row layout-wrap layout-align-start-start">
      <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
        <p className="flex-none">Upload Hubs Sheet</p>
        <FileUploader theme={theme} url={hubUrl} type="xlsx" text="Hub .xlsx" />
      </div>
      <AdminSearchableHubs
        theme={theme}
        hubs={hubs}
        adminDispatch={adminDispatch}
        sideScroll={false}
        handleClick={viewHub}
        seeAll={false}
      />
    </div>
  )
}

AdminHubsIndex.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  viewHub: PropTypes.func.isRequired,
  adminDispatch: PropTypes.shape({
    getHub: PropTypes.func
  }).isRequired
}

AdminHubsIndex.defaultProps = {
  theme: null,
  hubs: []
}

export default AdminHubsIndex
