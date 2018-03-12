import React from 'react'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { AdminSearchableHubs } from './AdminSearchables'
import FileUploader from '../../components/FileUploader/FileUploader'
import { adminHubs as hubsTip } from '../../constants'

export function AdminHubsIndex ({
  theme, hubs, viewHub, adminDispatch
}) {
  const hubUrl = '/admin/hubs/process_csv'
  const scUrl = '/admin/service_charges/process_csv'
  return (
    <div className="flex-100 layout-row layout-wrap layout-align-start-start">
      <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
        <div className="flex-33 layout-row layout-align-center-center layout-wrap">
          <p className="flex-100 center">Upload Hubs Sheet</p>
          <FileUploader
            theme={theme}
            url={hubUrl}
            type="xlsx"
            text="Hub .xlsx"
          />
        </div>
        <div className="flex-33 layout-row layout-align-center-center layout-wrap">
          <p className="flex-100 center">Upload Local Charges Sheet</p>
          <FileUploader
            theme={theme}
            url={scUrl}
            type="xlsx"
            text="Hub .xlsx"
          />
        </div>
      </div>
      <AdminSearchableHubs
        theme={theme}
        hubs={hubs}
        adminDispatch={adminDispatch}
        sideScroll={false}
        handleClick={viewHub}
        seeAll={false}
        icon="fa-info-circle"
        tooltip={hubsTip.manage}
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
