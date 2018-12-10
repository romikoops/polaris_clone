import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import FileUploader from '../../FileUploader/FileUploader'
import { RoundButton } from '../../RoundButton/RoundButton'
import DocumentsDownloader from '../../Documents/Downloader'
import SideOptionsBox from '../SideOptions/SideOptionsBox'
import CollapsingBar from '../../CollapsingBar/CollapsingBar'
import AdminHubsComp from './AdminHubsComp' // eslint-disable-line
import {
  capitalize
} from '../../../helpers'

export class AdminHubsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {}
    }
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
      t, theme, viewHub, toggleNewHub, documentDispatch, scope
    } = this.props

    const hubUrl = '/admin/hubs/process_csv'
    const scUrl = '/admin/service_charges/process_csv'
    const newButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text={t('admin:newHub')}
          active
          handleNext={() => toggleNewHub()}
          iconClass="fa-plus"
        />
      </div>
    )

    if (!this.props.hubs) {
      return ''
    }

    const modeOfTransports = ['ocean', 'air']

    const motBasedUploadButtons = (
      <div>
        {modeOfTransports.map(mot => (
          <div
            className={`${
              styles.action_section
            } flex-100 layout-row layout-align-center-center layout-wrap`}
          >
            <p className="flex-100 center">{t('admin:uploadLocalCharges', { mot: capitalize(mot) })}</p>
            <FileUploader
              theme={theme}
              url={scUrl}
              type="xlsx"
              text={t('admin:hubExcel')}
              dispatchFn={file => documentDispatch.uploadLocalCharges(file, mot)}
            />
          </div>
        ))}
      </div>
    )

    const motBasedDownloadButtons = (
      <div>
        {modeOfTransports.map(mot => (
          <div
            className={`${
              styles.action_section
            } flex-100 layout-row layout-wrap layout-align-center-center`}
          >
            <p className="flex-100 center">{t('admin:downloadLocalCharges', { mot: capitalize(mot) })}</p>
            <DocumentsDownloader
              theme={theme}
              target="local_charges"
              options={{ mot }}
            />
          </div>
        ))}
      </div>
    )

    const actionNodes = [<SideOptionsBox
      header={t('admin:dataManager')}
      flexOptions="flex"
      content={(
        <div className="flex-100 layout-row layout-wrap layout-align-center-start">
          <CollapsingBar
            showArrow
            collapsed={!expander.upload}
            theme={theme}
            styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
            handleCollapser={() => this.toggleExpander('upload')}
            text={t('admin:uploadData')}
            faClass="fa fa-cloud-upload"
            content={(
              <div>
                <div
                  className={`${
                    styles.action_section
                  } flex-100 layout-row layout-align-center-center layout-wrap`}
                >
                  <p className="flex-100 center">{t('admin:uploadHubs')}</p>
                  <FileUploader
                    theme={theme}
                    url={hubUrl}
                    type="xlsx"
                    text={t('admin:hubExcel')}
                    dispatchFn={documentDispatch.uploadHubs}
                  />
                </div>
                {motBasedUploadButtons}
              </div>
            )}
          />
          <CollapsingBar
            showArrow
            collapsed={!expander.download}
            theme={theme}
            styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
            handleCollapser={() => this.toggleExpander('download')}
            text={t('admin:downloadData')}
            faClass="fa fa-cloud-download"
            content={(
              <div>
                <div
                  className={`${
                    styles.action_section
                  } flex-100 layout-row layout-wrap layout-align-center-center`}
                >
                  <p className="flex-100 center">{t('admin:downloadHubs')}</p>
                  <DocumentsDownloader theme={theme} target="hubs" />
                </div>
                {motBasedDownloadButtons}
              </div>
            )}
          />
          { scope.show_beta_features ? (
            <CollapsingBar
              showArrow
              collapsed={!expander.new}
              theme={theme}
              styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
              handleCollapser={() => this.toggleExpander('new')}
              text={t('admin:createNewHub')}
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
          ) : '' }
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
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  scope: PropTypes.objectOf(PropTypes.bool),
  viewHub: PropTypes.func.isRequired,
  toggleNewHub: PropTypes.func.isRequired,
  documentDispatch: PropTypes.shape({
    closeViewer: PropTypes.func,
    uploadHubs: PropTypes.func
  }).isRequired
}

AdminHubsIndex.defaultProps = {
  theme: null,
  hubs: [],
  scope: {}
}

export default withNamespaces('admin')(AdminHubsIndex)
