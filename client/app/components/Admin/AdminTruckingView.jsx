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
import { TruckingDisplayPanel } from './AdminAuxilliaries'
// import { NamedSelect } from '../NamedSelect/NamedSelect'
import DocumentsSelector from '../../components/Documents/Selector'
import { documentActions } from '../../actions'
import { AdminUploadsSuccess } from './Uploads/Success'
import DocumentsDownloader from '../../components/Documents/Downloader'

export class AdminTruckingView extends Component {
  static backToIndex () {
    history.goBack()
  }
  static getTruckingPricingKey (truckingPricing) {
    if (truckingPricing.zipcode) {
      return truckingPricing.zipcode
    }
    if (truckingPricing.city) {
      return truckingPricing.city
    }
    if (truckingPricing.distance) {
      return truckingPricing.distance
    }
    return ''
  }

  constructor (props) {
    super(props)
    this.state = {
      loadTypeBool: true,
      directionBool: true,
      truckType: '',
      filteredTruckingPricings: [],
      searchFilter: '',
      expander: {}
    }
  }

  componentWillMount () {
    if (this.props.truckingDetail && this.props.truckingDetail.truckingPricings) {
      const truckType = this.props.truckingDetail.truckingPricings[0].truckingPricing.truck_type
      if (truckType === 'cargo_item') {
        this.setState({ truckType: 'default' })
      } else {
        this.setState({ truckType })
      }
      this.handleSearchChange({ target: { value: '' } })
    }
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  filterTruckingPricingsByType (pricings) {
    const { loadTypeBool, directionBool, truckType } = this.state
    const loadTypeKey = loadTypeBool ? 'container' : 'cargo_item'
    const directionKey = directionBool ? 'pre' : 'on'
    return pricings
      .filter(pr => pr.truckingPricing.load_type === loadTypeKey)
      .filter(pr => pr.truckingPricing.carriage === directionKey)
      .filter(pr => pr.truckingPricing.truck_type === truckType)
  }

  toggleNew () {
    this.setState({ newRow: !this.state.newRow })
  }
  selectTruckingPricing (truckingPricing) {
    this.setState({ currentTruckingPricing: truckingPricing.truckingPricing.id })
  }
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }
  handleUpload (file, dir, type) {
    const { adminDispatch, truckingDetail } = this.props
    const { hub } = truckingDetail
    const url = `/admin/trucking/trucking_pricings/${hub.id}`
    adminDispatch.uploadTrucking(url, file, dir)
  }
  handleLoadTypeToggle (value) {
    this.setState({ loadTypeBool: !this.state.loadTypeBool }, () => {
      this.handleSearchChange({ target: { value: '' } })
    })
  }

  handleTruckToggle (value) {
    this.setState({ truckBool: !this.state.truckBool }, () => {
      this.handleSearchChange({ target: { value: '' } })
    })
  }
  handleDirectionToggle (value) {
    this.setState({ directionBool: !this.state.directionBool }, () => {
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
      filteredTruckingPricings,
      searchFilter,
      currentTruckingPricing,
      loadTypeBool,
      directionBool,
      truckBool
    } = this.state
    // const truckType = truckBool ? 'chassis' : 'side_lifter'
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
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    console.log('DOCUMENT!!!!!!')
    console.log(document)
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

    const { expander } = this.state
    const sectionStyle =
      theme && theme.colors
        ? { background: theme.colors.secondary, color: 'white' }
        : { background: 'darkslategrey', color: 'white' }
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
    const truckFilter = loadTypeBool
      ? (<div className="flex-100 layout-row layout-align-space-between-center">
        <div className="flex-90 layout-row layout-align-space-between-center">
          <p className="flex-none">Chassis</p>
          <div className="flex-5" />
          <Toggle
            className="flex-none"
            id="unitView"
            name="unitView"
            checked={truckBool}
            onChange={e => this.handleTruckToggle(e)}
          />
          <div className="flex-5" />
          <p className="flex-none">Side Lifter</p>
        </div>
      </div>) : ''
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start">
        {uploadStatus}
        <div className={`${styles.component_view} flex-80 layout-row layout-align-start-start`}>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_title
              }`}
            >
              <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
                {hub.name}
              </p>
            </div>
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_header
              }`}
            >
              <p className={` ${styles.sec_header_text} flex-none`}> Rates </p>
            </div>
            <div className="flex-100 layout-row layout-align-space-around-start layout-wrap">
              <div className="flex-25 layout-row layout-align-center-start layout-wrap">
                <div className="flex-100 layout-row layout-align-space-between-center">
                  <div className="flex-90 layout-row layout-align-space-between-center">
                    <p className="flex-none">LTL</p>
                    <div className="flex-5" />
                    <Toggle
                      className="flex-none"
                      id="unitView"
                      name="unitView"
                      checked={loadTypeBool}
                      onChange={e => this.handleLoadTypeToggle(e)}
                    />
                    <div className="flex-5" />
                    <p className="flex-none">FTL</p>
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
                {truckFilter}
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
        <div className=" flex-20 layout-row layout-wrap layout-align-center-start">
          <div
            className={`${
              styles.action_box
            } flex-95 layout-row layout-wrap layout-align-center-start`}
          >
            <div
              className={`${styles.side_title} flex-100 layout-row layout-align-start-center`}
              style={sectionStyle}
            >
              <i className="flex-none fa fa-bolt" />
              <h2 className="flex-none letter_3 no_m"> Actions </h2>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div
                className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                onClick={() => this.toggleExpander('upload')}
              >
                <div className="flex-90 layout-align-start-center layout-row">
                  <i className="flex-none fa fa-cloud-upload" />
                  <p className="flex-none">Upload Data</p>
                </div>
                <div className={`${styles.expander_icon} flex-10 layout-align-center-center`}>
                  {expander.upload ? (
                    <i className="flex-none fa fa-chevron-up" />
                  ) : (
                    <i className="flex-none fa fa-chevron-down" />
                  )}
                </div>
              </div>
              <div
                className={`${
                  expander.upload ? styles.open_filter : styles.closed_filter
                } flex-100 layout-row layout-wrap layout-align-center-start`}
              >
                <div
                  className={`${
                    styles.action_section
                  } flex-100 layout-row layout-align-center-center layout-wrap`}
                >
                  <p className="flex-90 center">Upload Trucking Zones Sheet</p>
                  <DocumentsSelector
                    theme={theme}
                    dispatchFn={(file, dir) => this.handleUpload(file, dir)}
                    type="xlsx"
                    text="Routes .xlsx"
                  />
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div
                className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                onClick={() => this.toggleExpander('download')}
              >
                <div className="flex-90 layout-align-start-center layout-row">
                  <i className="flex-none fa fa-cloud-download" />
                  <p className="flex-none">Download Data</p>
                </div>
                <div className={`${styles.expander_icon} flex-10 layout-align-center-center`}>
                  {expander.download ? (
                    <i className="flex-none fa fa-chevron-up" />
                  ) : (
                    <i className="flex-none fa fa-chevron-down" />
                  )}
                </div>
              </div>
              <div
                className={`${
                  expander.download ? styles.open_filter : styles.closed_filter
                } flex-100 layout-row layout-wrap layout-align-center-start`}
              >
                <div
                  className={`${
                    styles.action_section
                  } flex-100 layout-row layout-wrap layout-align-center-center`}
                >
                  <p className="flex-100 center">Download Cargo Item Sheet</p>
                  <DocumentsDownloader
                    theme={theme}
                    target="trucking"
                    options={{ hub_id: hub.id, load_type: 'cargo_item' }}
                  />
                </div>
                <div
                  className={`${
                    styles.action_section
                  } flex-100 layout-row layout-wrap layout-align-center-center`}
                >
                  <p className="flex-100 center">Download Container Sheet</p>
                  <DocumentsDownloader
                    theme={theme}
                    target="trucking"
                    options={{ hub_id: hub.id, load_type: 'container' }}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
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
