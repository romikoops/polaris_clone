import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
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
      t, theme, viewHub, documentDispatch, user, scope
    } = this.props

    const hubUrl = '/admin/hubs/process_csv'
    const scUrl = '/admin/service_charges/process_csv'

    if (!this.props.hubs) {
      return ''
    }

    const modeOfTransports = ['all']

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
          { user.internal || scope.feature_uploaders ? (
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
                  <div
                    className={`${
                      styles.action_section
                    } flex-100 layout-row layout-align-center-center layout-wrap`}
                  >
                    <p className="flex-100 center">{t('admin:uploadChargeCategories')}</p>
                    <FileUploader
                      theme={theme}
                      url={hubUrl}
                      type="xlsx"
                      text={t('admin:chargeCategoriesExcel')}
                      dispatchFn={documentDispatch.uploadChargeCategories}
                    />
                  </div>
                  <div
                    className={`${
                      styles.action_section
                    } flex-100 layout-row layout-align-center-center layout-wrap`}
                  >
                    <p className="flex-100 center">{t('admin:uploadNotes')}</p>
                    <FileUploader
                      theme={theme}
                      url={hubUrl}
                      type="xlsx"
                      text={t('admin:notesExcel')}
                      dispatchFn={documentDispatch.uploadNotes}
                    />
                  </div>
                  {motBasedUploadButtons}
                </div>
              )}
            />
          ) : '' }
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
                <div
                  className={`${
                    styles.action_section
                  } flex-100 layout-row layout-wrap layout-align-center-center`}
                >
                  <p className="flex-100 center">{t('admin:downloadChargeCategories')}</p>
                  <DocumentsDownloader theme={theme} target="charge_categories" />
                </div>
                {motBasedDownloadButtons}
              </div>
            )}
          />
        </div>
      )}
    />]

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding_left padding_top">
        <AdminHubsComp
          actionNodes={actionNodes}
          handleClick={viewHub}
        />
      </div>

    )
  }
}

AdminHubsIndex.defaultProps = {
  theme: null,
  hubs: [],
  scope: {}
}

export default withNamespaces('admin')(AdminHubsIndex)
