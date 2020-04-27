import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import Tabs from '../Tabs/Tabs'
import Tab from '../Tabs/Tab'
import AdminTrucking from './AdminTrucking'
import AdminPricingList from './Pricing/index'
import { adminPricing as priceTip, moTOptions } from '../../constants'
import { capitalize, camelToSnakeCase } from '../../helpers'
import styles from './Admin.scss'
import FileUploader from '../FileUploader/FileUploader'
import DocumentsDownloader from '../Documents/Downloader'
import SideOptionsBox from './SideOptions/SideOptionsBox'
import CollapsingBar from '../CollapsingBar/CollapsingBar'

export class AdminPricingsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {}
    }
    this.viewPricings = this.viewPricings.bind(this)
  }

  componentDidMount () {
    window.scrollTo(0, 0)
  }

  viewPricings (itinerary) {
    const { adminDispatch } = this.props
    adminDispatch.getItineraryPricings(itinerary.id, null, true)
  }

  pricingUpload (file, mot, loadType, isOpen) {
    const { documentDispatch } = this.props
    documentDispatch.uploadPricings(file, mot, loadType, isOpen)
  }

  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }

  downloadTargets () {
    const { scope, t } = this.props
    const targets = []
    Object.keys(scope.modes_of_transport).forEach((mot) => {
      ['container', 'cargo_item'].forEach((key) => {
        if (get(scope, ['modes_of_transport', mot, key], false)) {
          targets.push({ label: `${capitalize(mot)}: ${t(`common:${key}`)}`, value: { mot, load_type: key } })
        }
      })
    })

    return targets
  }

  render () {
    const {
      t, theme, documentDispatch, user, scope
    } = this.props
    const { expander } = this.state

    const loadTypeOptions = {
      air: { cargoItem: 'LCL' },
      ocean: { cargoItem: 'LCL', container: 'FCL' },
      rail: { cargoItem: 'LCL', container: 'FCL' },
      truck: { cargoItem: 'LTL', container: 'FTL' }
    }

    const uploadPricingText = t('admin:uploadPricing')
    const downloadPricingText = t('admin:downloadPricing')

    const uploadButtons = (<div
      className={`${styles.open_filter} flex-100 layout-row layout-wrap layout-align-center-start`}
    >
      <div
        className={`${
          styles.action_section
        } flex-100 layout-row layout-wrap layout-align-center-center`}
      >
        <p className="flex-100">{uploadPricingText}</p>
        <FileUploader
          theme={theme}
          dispatchFn={file => this.pricingUpload(file)}
          tooltip={priceTip.upload_lcl}
          type="xlsx"
          size="full"
          text={t('admin:dedicatedPricing')}
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
          type="xlsx"
          text={t('admin:chargeCategoriesExcel')}
          dispatchFn={documentDispatch.uploadChargeCategories}
        />
      </div>
    </div>
    )
    const downloadButtons = (<div
      className={`${styles.open_filter} 
                  ${styles.download_section}
                   flex-100 layout-row layout-wrap layout-align-center-start`}
    >
      <div
        className={`${
          styles.action_section
        } flex-100 layout-row layout-wrap layout-align-center-center`}
      >
        <p className="flex-100">{downloadPricingText}</p>
        <DocumentsDownloader
          theme={theme}
          target="pricings"
          targetOptions={this.downloadTargets()}
          size="full"
        />
      </div>
      <div
        className={`${
          styles.action_section
        } flex-100 layout-row layout-wrap layout-align-center-center`}
      >
        <p className="flex-100 center">{t('admin:downloadChargeCategories')}</p>
        <DocumentsDownloader theme={theme} target="charge_categories" />
      </div>
    </div>
    )
    const tabs = [(
      <Tab
        tabTitle={t('admin:mainCarriage')}
        theme={theme}
      >
        <div className="flex-100 layout-row">
          <div className="flex-80 layout-row layout-align-center-start">
            <AdminPricingList viewPricings={this.viewPricings} />
          </div>
          <div className="flex-20 layout-row layout-align-end-start">
            <div className="hide-sm hide-xs layout-row layout-wrap  flex-100">
              <SideOptionsBox
                header={t('admin:dataManager')}
                flexOptions="flex-100"
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
                        content={uploadButtons}
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
                      content={downloadButtons}
                    />
                  </div>
                )}
              />
              <p className={`flex-100 ${styles.tip}`}>{t('admin:pricingsTip')}</p>
            </div>
          </div>
        </div>

      </Tab>
    )]
    tabs.push(<Tab
      tabTitle={t('admin:preOnCarriage')}
      theme={theme}
    >
      <AdminTrucking
        theme={theme}
      />
    </Tab>)

    return (
      <div className="flex-100 layout-row layout-align-end-start">
        <div className="flex-95 layout-row layout-align-center-start">
          <Tabs
            wrapperTabs="layout-row flex-90 margin_bottom"
            paddingFixes
          >
            {tabs}
          </Tabs>
        </div>
      </div>
    )
  }
}

AdminPricingsIndex.defaultProps = {
  theme: null,
  clients: [],
  hubHash: {},
  pricingData: null,
  scope: null
}

export default withNamespaces('admin')(AdminPricingsIndex)
