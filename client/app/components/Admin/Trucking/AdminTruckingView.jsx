import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import GmapsWrapper from '../../../hocs/GmapsWrapper'
import '../../../styles/react-toggle.scss'
import styles from '../Admin.scss'
import {
  history
} from '../../../helpers'
import TruckingCoverage from './Coverage'
import TruckingCoverageEditor from './CoverageEditor'
import TruckingTable from './Table'
import { documentActions } from '../../../actions'
import AdminUploadsSuccess from '../Uploads/Success'
import GreyBox from '../../GreyBox/GreyBox'
import LegacyFileHandlers from './LegacyFileHandlers'
import GroupFileHandlers from './GroupFileHandlers'

export class AdminTruckingView extends Component {
  static backToIndex () {
    history.goBack()
  }

  constructor (props) {
    super(props)
    this.state = {
      targetTruckingPricing: false,
      coverageEditor: false
    }
    this.setTargetTruckingId = this.setTargetTruckingId.bind(this)
    this.handleUpload = this.handleUpload.bind(this)
    this.toggleEditor = this.toggleEditor.bind(this)
  }

  componentDidMount () {
    window.scrollTo(0, 0)
  }

  setTargetTruckingId (id) {
    this.setState({ targetTruckingPricing: id })
  }

  handleUpload (file, group) {
    const { adminDispatch, truckingDetail } = this.props
    const { hub } = truckingDetail
    const url = `/admin/trucking/trucking_pricings/${hub.id}`
    adminDispatch.uploadTrucking(url, file, group)
  }

  closeSuccessDialog () {
    const { documentDispatch } = this.props
    documentDispatch.closeViewer()
  }

  toggleEditor () {
    this.setState(prevState => ({ coverageEditor: !prevState.coverageEditor }))
  }

  render () {
    const {
      t, theme, truckingDetail, document, scope
    } = this.props
    if (!truckingDetail) {
      return ''
    }

    const {
      targetTruckingPricing, coverageEditor
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
    const { hub, groups } = truckingDetail

    const editorView = (
      <div className="flex-100 layout-row layout-align-space-around-start layout-wrap">
        <GreyBox
          wrapperClassName="flex layout-row layout-align-start-start layout-wrap margin_10"
          contentClassName="flex-100 layout-row layout-align-start-start layout-wrap"
        > 
          <GmapsWrapper
            location={hub}
            back={() => this.toggleEditor()}
            targetId={targetTruckingPricing}
            component={TruckingCoverageEditor}
          />
        </GreyBox>
      </div>
    
    )
    
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
    const groupOptions = [{ label: 'All', value: 'all' }]
    if (groups.length) {
      groups.forEach((g) => {
        groupOptions.push({ label: g.name, value: g.id })
      })
    }
    const viewBoxes = [
      (<div className="flex-40 layout-row layout-align-space-around-start layout-wrap">
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
      </div>)
      , (
        <div className="flex-60 layout-row layout-align-space-around-start layout-wrap">
          <GreyBox
            wrapperClassName="flex layout-row layout-align-start-start layout-wrap margin_10"
            contentClassName="flex-100 layout-row layout-align-start-start layout-wrap"
          >
            <TruckingTable
              setTargetTruckingId={this.setTargetTruckingId}
              toggleEditor={() => this.toggleEditor()}
            />
          </GreyBox>
        </div>)
    ]
    const renderView = coverageEditor ? editorView : viewBoxes

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start">
        {uploadStatus}
        <div className={`${styles.component_view} flex-100 layout-row layout-align-start-start`}>
          <div className="layout-row flex-100 layout-wrap layout-align-start-start">
            <GreyBox
              wrapperClassName="flex-100 layout-row layout-align-start-center margin_10"
              contentClassName="flex-100 layout-row layout-align-start-center"
            >
              { scope.base_pricing ? (
                <GroupFileHandlers handleUpload={this.handleUpload} hub={hub} theme={theme} groupOptions={groupOptions} />
              ) : (   
                <LegacyFileHandlers handleUpload={this.handleUpload} hub={hub} theme={theme} />)
              }
            </GreyBox>
            {renderView}

          </div>
          {styleTagJSX}
        </div>
      </div>
    )
  }
}

AdminTruckingView.defaultProps = {
  theme: null,
  truckingDetail: null,
  document: {},
  documentDispatch: {}
}
function mapStateToProps (state) {
  const { document, app } = state
  const { scope } = app.tenant

  return {
    document,
    scope
  }
}
function mapDispatchToProps (dispatch) {
  return {
    documentDispatch: bindActionCreators(documentActions, dispatch)
  }
}

export default withNamespaces('admin')(connect(mapStateToProps, mapDispatchToProps)(AdminTruckingView))
