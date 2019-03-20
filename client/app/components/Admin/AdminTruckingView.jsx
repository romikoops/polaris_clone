import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import Fuse from 'fuse.js'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import GmapsWrapper from '../../hocs/GmapsWrapper'
import '../../styles/react-toggle.scss'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import {
  history
} from '../../helpers'
import DocumentsSelector from '../Documents/Selector'
import TruckingCoverage from './Trucking/Coverage/index'
import TruckingTable from './Trucking/Table'
import { documentActions } from '../../actions'
import AdminUploadsSuccess from './Uploads/Success'
import DocumentsDownloader from '../Documents/Downloader'
import GreyBox from '../GreyBox/GreyBox'


export class AdminTruckingView extends Component {
  static backToIndex () {
    history.goBack()
  }

  constructor (props) {
    super(props)
    this.state = {
      targetTruckingPricing: false
    }
    this.setTargetTruckingId = this.setTargetTruckingId.bind(this)
  }

  componentDidMount () {
    window.scrollTo(0, 0)
  
  }

  setTargetTruckingId (id) {
    this.setState({ targetTruckingPricing: id })
  }

  handleUpload (file, dir, type) {
    const { adminDispatch, truckingDetail } = this.props
    const { hub } = truckingDetail
    const url = `/admin/trucking/trucking_pricings/${hub.id}`
    adminDispatch.uploadTrucking(url, file, dir)
  }

  closeSuccessDialog () {
    const { documentDispatch } = this.props
    documentDispatch.closeViewer()
  }

  render () {
    const {
      t, theme, truckingDetail, document
    } = this.props
    if (!truckingDetail) {
      return ''
    }

    const {
      targetTruckingPricing
    } = this.state

    const uploadStatus = document.viewer ? (
      <AdminUploadsSuccess
        theme={theme}
        data={document.results}
        closeDialog={() => this.closeSuccessDialog()}
      />
    ) : (
      ''
    )
    const { hub } = truckingDetail
    const toggleCSS = `
      .react-toggle--checked .react-toggle-track {
        background:
          ${theme.colors.brightPrimary} !important;
        border: 0.5px solid rgba(0, 0, 0, 0);
      }
      .react-toggle-track {
        background: ${theme.colors.brightSecondary} !important;
      }
      .react-toggle:hover .react-toggle-track{
        background: rgba(0, 0, 0, 0.5) !important;
      }
    `
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start">
        {uploadStatus}
        <div className={`${styles.component_view} flex-100 layout-row layout-align-start-start`}>
          <div className="layout-row flex-100 layout-wrap layout-align-start-start">
            <GreyBox 
              wrapperClassName="flex-100 layout-row layout-align-start-center margin_10"
              contentClassName="flex-100 layout-row layout-align-start-center"
            >
              <div
                className={`${
                  styles.action_section
                } flex-100 flex-gt-sm-33 layout-row layout-align-center-center layout-wrap`}
              >
                <p className="flex-90 flex-gt-sm-50  center">{t('admin:uploadTruckingZonesSheet')}</p>
                <DocumentsSelector
                  theme={theme}
                  dispatchFn={(file, dir) => this.handleUpload(file, dir)}
                  type="xlsx"
                  text={t('admin:routesExcel')}
                />
              </div>
              <div
                className={`${
                  styles.action_section
                } flex-100 flex-gt-sm-33 layout-row layout-wrap layout-align-center-center`}
              >
                <p className="flex-100 flex-gt-sm-50 center">{t('admin:downloadCargoItemSheet')}</p>
                <DocumentsDownloader
                  theme={theme}
                  target="trucking"
                  options={{ hub_id: hub.id, load_type: 'cargo_item' }}
                />
              </div>
              <div
                className={`${
                  styles.action_section
                } flex-100 flex-gt-sm-33 layout-row layout-wrap layout-align-center-center`}
              >
                <p className="flex-100 flex-gt-sm-50 center">{t('admin:downloadContainerSheet')}</p>
                <DocumentsDownloader
                  theme={theme}
                  target="trucking"
                  options={{ hub_id: hub.id, load_type: 'container' }}
                />
              </div>
            </GreyBox>
            <div className="flex-40 layout-row layout-align-space-around-start layout-wrap">
              <GreyBox 
                wrapperClassName="flex layout-row layout-align-start-start layout-wrap margin_10"
                contentClassName="flex-100 layout-row layout-align-start-start layout-wrap"
              >
                <GmapsWrapper
                  onMapClick={this.setCurrentTruckingPricing}
                  location={hub}
                  targetId={targetTruckingPricing}
                  component={TruckingCoverage}
                />
              </GreyBox>
            </div>

            <div className="flex-60 layout-row layout-align-space-around-start layout-wrap">
              <GreyBox 
                wrapperClassName="flex layout-row layout-align-start-start layout-wrap margin_10"
                contentClassName="flex-100 layout-row layout-align-start-start layout-wrap"
              >
                <TruckingTable setTargetTruckingId={this.setTargetTruckingId}/>
              </GreyBox>
            </div>

          </div>
          {styleTagJSX}
        </div>
       
      </div>
    )
  }
}
AdminTruckingView.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  adminDispatch: PropTypes.shape({
    uploadTrucking: PropTypes.func
  }).isRequired,
  truckingDetail: PropTypes.shape({
    truckingHub: PropTypes.object,
    truckingPricings: PropTypes.array,
    pricing: PropTypes.object
  }),
  document: PropTypes.objectOf(PropTypes.any),
  documentDispatch: PropTypes.objectOf(PropTypes.func)
}

AdminTruckingView.defaultProps = {
  theme: null,
  truckingDetail: null,
  document: {},
  documentDispatch: {}
}
function mapStateToProps (state) {
  const { document } = state

  return {
    document
  }
}
function mapDispatchToProps (dispatch) {
  return {
    documentDispatch: bindActionCreators(documentActions, dispatch)
  }
}

export default withNamespaces('admin')(connect(mapStateToProps, mapDispatchToProps)(AdminTruckingView))
