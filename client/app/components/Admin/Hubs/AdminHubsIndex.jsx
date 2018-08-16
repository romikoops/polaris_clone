import React, { Component } from 'react'

import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import FileUploader from '../../../components/FileUploader/FileUploader'

import { RoundButton } from '../../RoundButton/RoundButton'
import DocumentsDownloader from '../../../components/Documents/Downloader'

import SideOptionsBox from '../SideOptions/SideOptionsBox'
import CollapsingBar from '../../CollapsingBar/CollapsingBar'
import AdminHubsComp from './AdminHubsComp' // eslint-disable-line

export class AdminHubsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {}
    }
    // this.toggleExpander = this.toggleExpander.bind(this)
  }

  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }

  render () {
    const { expander } = this.state
    const {
      theme, viewHub, toggleNewHub, documentDispatch
    } = this.props
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
    if (!this.props.hubs) {
      return ''
    }

    const actionNodes = [<SideOptionsBox
      header="Data manager"
      content={(
        <div className="flex-100 layout-row layout-wrap layout-align-center-start">
          <CollapsingBar
            showArrow
            collapsed={!expander.upload}
            theme={theme}
            styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
            handleCollapser={() => this.toggleExpander('upload')}
            text="Upload Data"
            faClass="fa fa-cloud-upload"
            content={(
              <div>
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
            )}
          />
          <CollapsingBar
            showArrow
            collapsed={!expander.download}
            theme={theme}
            styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
            handleCollapser={() => this.toggleExpander('download')}
            text="Download Data"
            faClass="fa fa-cloud-download"
            content={(
              <div>
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
                  <p className="flex-100 center">Download Ocean Local Charges Sheet</p>
                  <DocumentsDownloader
                    theme={theme}
                    target="local_charges"
                    options={{ mot: 'ocean' }}
                  />
                </div>
                <div
                  className={`${
                    styles.action_section
                  } flex-100 layout-row layout-wrap layout-align-center-center`}
                >
                  <p className="flex-100 center">Download Air Local Charges Sheet</p>
                  <DocumentsDownloader
                    theme={theme}
                    target="local_charges"
                    options={{ mot: 'air' }}
                  />
                </div>
              </div>
            )}
          />
          <CollapsingBar
            showArrow
            collapsed={!expander.new}
            theme={theme}
            styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
            handleCollapser={() => this.toggleExpander('new')}
            text="Create New Hub"
            faClass="fa fa-plus-circle"
            content={(
              <div
                className={`${
                  styles.action_section
                } flex-100 layout-row layout-wrap layout-align-center-center`}
              >
                {newButton}
              </div>
            )}
          />
        </div>
      )}
    />]

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding_left">
        <AdminHubsComp
          actionNodes={actionNodes}
          handleClick={viewHub}
        />
      </div>

    )
  }
}

AdminHubsIndex.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  viewHub: PropTypes.func.isRequired,
  toggleNewHub: PropTypes.func.isRequired,
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
