import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import Fuse from 'fuse.js'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import Toggle from 'react-toggle'
import '../../styles/react-toggle.scss'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { history } from '../../helpers'
import { RoundButton } from '../RoundButton/RoundButton'
import { TruckingDisplayPanel } from './AdminAuxilliaries'
// import { NamedSelect } from '../NamedSelect/NamedSelect'
import DocumentsSelector from '../../components/Documents/Selector'
import { documentActions } from '../../actions'
import { AdminUploadsSuccess } from './Uploads/Success'

export class AdminTruckingView extends Component {
  static backToIndex () {
    history.goBack()
  }
  static getTruckingPricingKey (truckingPricing) {
    if (truckingPricing.zipcode) {
      return truckingPricing.zipcode.join(' - ')
    }
    if (truckingPricing.city) {
      return truckingPricing.city[0]
    }
    if (truckingPricing.distance) {
      return truckingPricing.distance.join(' - ')
    }
    return ''
  }

  constructor (props) {
    super(props)
    this.state = {
      loadTypeBool: true,
      directionBool: true,
      filteredTruckingPricings: [],
      searchFilter: ''
    }
  }
  componentWillMount () {
    if (this.props.truckingDetail && this.props.truckingDetail.truckingPricings) {
      this.handleSearchChange({ target: { value: '' } })
    }
  }

  filterTruckingPricingsByType (pricings) {
    const { loadTypeBool, directionBool } = this.state
    const loadTypeKey = loadTypeBool ? 'container' : 'cargo_item'
    const directionKey = directionBool ? 'pre' : 'on'
    return pricings
      .filter(pr => pr.truckingPricing.load_type === loadTypeKey)
      .filter(pr => pr.truckingPricing.carriage === directionKey)
  }

  toggleNew () {
    this.setState({ newRow: !this.state.newRow })
  }
  selectTruckingPricing (truckingPricing) {
    this.setState({ currentTruckingPricing: truckingPricing.truckingPricing.id })
  }
  handleUpload (file, dir, type) {
    const { adminDispatch, truckingDetail } = this.props
    const { hub } = truckingDetail
    const url = `/admin/trucking/trucking_pricings/${hub.id}`
    adminDispatch.uploadTrucking(url, file, dir)
  }
  handleLoadTypeToggle (value) {
    // const { searchFilter } = this.state
    this.setState({ loadTypeBool: !this.state.loadTypeBool }, function () {
      this.handleSearchChange({ target: { value: '' } })
    })
  }
  handleDirectionToggle (value) {
    // const { searchFilter } = this.state
    this.setState({ directionBool: !this.state.directionBool }, function () {
      this.handleSearchChange({ target: { value: '' } })
    })
  }
  closeSuccessDialog () {
    const { documentDispatch } = this.props
    documentDispatch.closeViewer()
  }
  handleSearchChange (event) {
    if (event.target.value === '') {
      this.setState({
        filteredTruckingPricings:
          this.filterTruckingPricingsByType(this.props.truckingDetail.truckingPricings)
      })
      return
    }
    const search = (key) => {
      const options = {
        shouldSort: true,
        tokenize: true,
        threshold: 0.2,
        location: 0,
        distance: 50,
        maxPatternLength: 32,
        minMatchCharLength: 5,
        keys: key
      }
      const fuse = new Fuse(this.props.truckingDetail.truckingPricings, options)
      return fuse.search(event.target.value)
    }

    const filteredTruckingPricings = search(['zipcode', 'city', 'distance'])
    // ;
    this.setState({
      filteredTruckingPricings: this.filterTruckingPricingsByType(filteredTruckingPricings),
      searchFilter: event.target.value
    })
  }
  render () {
    const {
      theme, truckingDetail, adminDispatch, document
    } = this.props
    if (!truckingDetail) {
      return ''
    }

    const {
      newRow,
      filteredTruckingPricings,
      searchFilter,
      currentTruckingPricing,
      loadTypeBool,
      directionBool
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
    // const nexus = truckingHub ? nexuses.filter(n => n.id === truckingHub.nexus_id)[0] : {}
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const newButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          active
          text="New"
          handleNext={() => this.toggleNew()}
          iconClass="fa-plus"
        />
      </div>
    )
    const truckingPricingToDisplay =
      truckingDetail.truckingPricings
        .filter(tp => tp.truckingPricing.id === currentTruckingPricing)[0]
    const displayPanel = (
      <TruckingDisplayPanel
        theme={theme}
        truckingInstance={truckingPricingToDisplay}
        closeView={this.closeQueryView}
        adminDispatch={adminDispatch}
      />
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
    const nothingSelected = (
      <div className="layout-fill layout-row layout-align-center-center">
        <h3 className="flex-none">Please select from the side menu to begin</h3>
      </div>
    )
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''
    const truckView = currentTruckingPricing ? displayPanel : nothingSelected

    // const uploadOptions = [
    //   { value: 'import', label: 'Import Only' },
    //   { value: 'export', label: 'Export Only' },
    //   { value: 'either', label: 'Import/Export' }
    // ]
    const searchResults =
      filteredTruckingPricings.length > 0 ? (
        filteredTruckingPricings.map(tp => (
          <div
            className={`flex-100 layout-row layout-align-center-center pointy layout-wrap ${
              styles.trucking_display_cell
            }`}
            key={v4()}
            onClick={() => this.selectTruckingPricing(tp)}
          >
            <p className="flex-none"> {AdminTruckingView.getTruckingPricingKey(tp)}</p>
          </div>
        ))
      ) : (
        <div className="flex-100 layout-row layout-align-center-center">
          <p className="flex-none">No truckings available</p>
        </div>
      )

    const panelStyle = newRow ? styles.showPanel : styles.hidePanel
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {hub.name}
          </p>
          {newButton}
        </div>
        <div
          className={`${panelStyle} ${
            styles.panelDefault
          } flex-100 layout-row layout-align-space-between-center`}
        >
          <div className="flex-33 layout-row layout-wrap layout-align-center-center">
            <p className="flex-90 center">Create New Trucking Pricing</p>
            <RoundButton
              theme={theme}
              size="small"
              active
              text="New Pricing"
              handleNext={() => adminDispatch.goTo('/admin/trucking/new/creator')}
              iconClass="fa-plus"
            />
          </div>
          <div className="flex-33 layout-row layout-wrap layout-align-center-center">
            <p className="flex-90 center">Upload Trucking Zones Sheet</p>
            <DocumentsSelector
              theme={theme}
              dispatchFn={(file, dir) => this.handleUpload(file, dir)}
              type="xlsx"
              text="Routes .xlsx"
            />
          </div>
          <div className="flex-33 layout-row layout-wrap layout-align-center-center">
            <p className="flex-none">{document.viewer}</p>
          </div>
        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          {uploadStatus}
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Rates </p>
          </div>
          <div className="flex-100 layout-row layout-align-space-around-start layout-wrap">
            <div className="flex-25 layout-row layout-align-center-start layout-wrap">
              <div className="flex-100 layout-row layout-align-space-between-center">
                <div className="flex-90 layout-row layout-align-space-between-center">
                  <p className="flex-none">LCL</p>
                  <div className="flex-5" />
                  <Toggle
                    className="flex-none"
                    id="unitView"
                    name="unitView"
                    checked={loadTypeBool}
                    onChange={e => this.handleLoadTypeToggle(e)}
                  />
                  <div className="flex-5" />
                  <p className="flex-none">FCL</p>
                </div>
              </div>
              <div className="flex-100 layout-row layout-align-space-between-center">
                <div className="flex-90 layout-row layout-align-space-between-center">
                  <p className="flex-none">Export</p>
                  <div className="flex-5" />
                  <Toggle
                    className="flex-none"
                    id="unitView"
                    name="unitView"
                    checked={directionBool}
                    onChange={e => this.handleDirectionToggle(e)}
                  />
                  <div className="flex-5" />
                  <p className="flex-none">Import</p>
                </div>
              </div>
              <div className="flex-100 layout-row layout-alignstart-center input_box_full">
                <input
                  type="text"
                  value={searchFilter}
                  placeholder="Search Trucking Zones"
                  onChange={e => this.handleSearchChange(e)}
                />
              </div>
              <div
                className={`flex-100 layout-row layout-align-center-start layout-wrap ${
                  styles.trucking_search_results
                }`}
              >
                {searchResults}
              </div>
            </div>
            <div className="flex-75 layout-row layout-align-center-start layout-wrap">
              {truckView}
            </div>
          </div>
        </div>
        {styleTagJSX}
      </div>
    )
  }
}
AdminTruckingView.propTypes = {
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

export default connect(mapStateToProps, mapDispatchToProps)(AdminTruckingView)
