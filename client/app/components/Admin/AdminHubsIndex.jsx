import React from 'react'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { AdminSearchableHubs } from './AdminSearchables'
import FileUploader from '../../components/FileUploader/FileUploader'
import { adminHubs as hubsTip } from '../../constants'
import { RoundButton } from '../RoundButton/RoundButton'
import DocumentsDownloader from '../../components/Documents/Downloader'

export function AdminHubsIndex ({
  theme,
  hubs,
  viewHub,
  adminDispatch,
  toggleNewHub,
  documentDispatch
}) {
  const hubUrl = '/admin/hubs/process_csv'
  const scUrl = '/admin/service_charges/process_csv'
  const newButton = (
    <div className="flex-none layout-row">
      <RoundButton
        theme={theme}
        size="small"
        text="New Hub"
        active
        handleNext={() => toggleNewHub()}
        iconClass="fa-plus"
      />
    </div>
  )

  return (
    <div className="flex-100 layout-row layout-wrap layout-align-space-around-start">
      <div className={`${styles.component_view} flex-80 layout-row layout-align-start-start`}>
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
                <p className="flex-100 center">Upload Hubs Sheet</p>
                <FileUploader
                  theme={theme}
                  url={hubUrl}
                  type="xlsx"
                  text="Hub .xlsx"
                  dispatchFn={documentDispatch.uploadHubs}
                />
              </div>
              <div
                className={`${
                  styles.action_section
                } flex-100 layout-row layout-align-center-center layout-wrap`}
              >
                <p className="flex-100 center">Upload Local Charges Sheet</p>
                <FileUploader
                  theme={theme}
                  url={scUrl}
                  type="xlsx"
                  text="Hub .xlsx"
                  dispatchFn={documentDispatch.uploadLocalCharges}
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
                <p className="flex-100 center">Download Hubs Sheet</p>
                <DocumentsDownloader theme={theme} target="hubs" />
              </div>
              <div
                className={`${
                  styles.action_section
                } flex-100 layout-row layout-wrap layout-align-center-center`}
              >
                <p className="flex-100 center">Download Local Charges Sheet</p>
                <DocumentsDownloader theme={theme} target="local_charges" />
              </div>
            </div>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-center-start">
            <div
              className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
            >
              <i className="flex-none fa fa-plus-circle" />
              <p className="flex-none">Create New Hub</p>
            </div>
            <div
              className={`${
                styles.action_section
              } flex-100 layout-row layout-wrap layout-align-center-center`}
            >
              {newButton}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

AdminHubsIndex.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  viewHub: PropTypes.func.isRequired,
  toggleNewHub: PropTypes.func.isRequired,
  adminDispatch: PropTypes.shape({
    getHub: PropTypes.func
  }).isRequired,
  documentDispatch: PropTypes.shape({
    closeViewer: PropTypes.func,
    uploadHubs: PropTypes.func
  }).isRequired
}

AdminHubsIndex.defaultProps = {
  theme: null,
  hubs: []
}

export default AdminHubsIndex
