import React from 'react'
import PropTypes from '../../prop-types'
import { AdminSearchableClients } from './AdminSearchables'
import styles from './Admin.scss'
import FileUploader from '../../components/FileUploader/FileUploader'

export function AdminClientsIndex ({ theme, clients, adminDispatch }) {
  const hubUrl = '/admin/clients/process_csv'
  return (
    <div className="flex-100 layout-row layout-wrap layout-align-start-start">
      <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
        <p className="flex-none">Upload Clients Sheet</p>
        <FileUploader theme={theme} url={hubUrl} type="xlsx" text="Client .xlsx" />
      </div>
      <AdminSearchableClients theme={theme} clients={clients} adminDispatch={adminDispatch} />
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
