import React from 'react'
import PropTypes from '../../prop-types'
import { AdminSearchableClients } from './AdminSearchables'
import styles from './Admin.scss'
import FileUploader from '../../components/FileUploader/FileUploader'
import { adminClientsTooltips as clientTip } from '../../constants'
import DocumentsDownloader from '../../components/Documents/Downloader'

export function AdminClientsIndex ({ theme, clients, adminDispatch }) {
  const hubUrl = '/admin/clients/process_csv'
  return (
    <div className="flex-100 layout-row layout-wrap layout-align-space-around-start">
      {/* {uploadStatus} */}
      <div className={`${styles.component_view} flex-80 layout-row layout-align-start-start`}>
        <AdminSearchableClients
          theme={theme}
          clients={clients}
          adminDispatch={adminDispatch}
          tooltip={clientTip.manage}
          showTooltip
        />
      </div>
      <div className=" flex-20 layout-row layout-wrap layout-align-center-start">
        <div
          className={`${
            styles.action_box
          } flex-95 layout-row layout-wrap layout-align-center-start`}
        >
          <div className="flex-100 layout-row layout-align-center-center">
            <h2 className="flex-none letter_3"> Actions </h2>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-center-start">
            <div
              className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
            >
              <i className="flex-none fa fa-cloud-upload" />
              <p className="flex-none">Upload Data</p>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div
                className={`${
                  styles.action_section
                } flex-100 layout-row layout-align-center-center layout-wrap`}
              >
                <p className="flex-none">Upload Clients Sheet</p>
                <FileUploader
                  theme={theme}
                  url={hubUrl}
                  type="xlsx"
                  text="Client .xlsx"
                  tooltip={clientTip.upload}
                />
              </div>
            </div>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-center-start">
            <div
              className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
            >
              <i className="flex-none fa fa-cloud-download" />
              <p className="flex-none">Download Data</p>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-space-around">
              <div
                className={`${
                  styles.action_section
                } flex-100 layout-row layout-wrap layout-align-center-center`}
              >
                <p className="flex-100 center">Download Clients Sheet</p>
                <DocumentsDownloader theme={theme} target="clients" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

AdminClientsIndex.propTypes = {
  theme: PropTypes.theme,
  clients: PropTypes.arrayOf(PropTypes.clients),
  adminDispatch: PropTypes.shape({
    getClient: PropTypes.func
  }).isRequired
}

AdminClientsIndex.defaultProps = {
  theme: null,
  clients: []
}

export default AdminClientsIndex
