import React, { Component } from 'react'
import { v4 } from 'uuid'
import Fuse from 'fuse.js'
// import Truncate from 'react-truncate'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import Toggle from 'react-toggle'
import '../../styles/react-toggle.scss'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import hubStyles from './Hubs/index.scss'
import {
  history,
  capitalize,
  nameToDisplay,
  switchIcon,
  gradientGenerator,
  renderHubType
} from '../../helpers'
import { TruckingDisplayPanel } from './AdminAuxilliaries'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import DocumentsSelector from '../../components/Documents/Selector'
import { documentActions } from '../../actions'
import { AdminUploadsSuccess } from './Uploads/Success'
import DocumentsDownloader from '../../components/Documents/Downloader'
import { cargoClassOptions } from '../../constants'
import AlternativeGreyBox from '../GreyBox/AlternativeGreyBox'
import SideOptionsBox from './SideOptions/SideOptionsBox'
import CollapsingBar from '../CollapsingBar/CollapsingBar'

function getTruckingPricingKey (truckingPricing) {
  if (truckingPricing.zipcode) {
    const joinedArrays = truckingPricing.zipcode.map(zArray => zArray.join(' - '))
    const endResult = joinedArrays.join(', ')

    return endResult
  }
  if (truckingPricing.city) {
    const joinedArrays = truckingPricing.city.map(zArray => zArray.join(' - '))
    const endResult = joinedArrays.join(', ')

    return endResult
  }
  if (truckingPricing.distance) {
    const joinedArrays = truckingPricing.distance.map(zArray => zArray.join(' - '))
    const endResult = joinedArrays.join(', ')

    return endResult
  }

  return ''
}

export class AdminTruckingView extends Component {
  static backToIndex () {
    history.goBack()
  }

  constructor (props) {
    super(props)
    this.state = {
      loadTypeBool: true,
      directionBool: true,
      truckBool: true,
      filteredTruckingPricings: [],
      searchFilter: '',
      cargoClass: { value: 'fcl_20', label: 'FCL 20ft' },
      expander: {}
    }
  }

  componentWillMount () {
    if (this.props.truckingDetail && this.props.truckingDetail.truckingPricings) {
      this.handleSearchChange({ target: { value: '' } })
    }
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  filterTruckingPricingsByType (pricings) {
    const {
      loadTypeBool, directionBool, truckBool, cargoClass
    } = this.state
    const loadTypeKey = loadTypeBool ? 'container' : 'cargo_item'
    const directionKey = directionBool ? 'pre' : 'on'
    const truckKey = truckBool ? 'chassis' : 'side_lifter'
    if (loadTypeBool) {
      return pricings
        .filter(pr => pr.truckingPricing.load_type === loadTypeKey)
        .filter(pr => pr.truckingPricing.carriage === directionKey)
        .filter(pr => pr.truckingPricing.truck_type === truckKey)
        .filter(pr => pr.truckingPricing.cargo_class === cargoClass.value)
    }

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
      if (this.state.loadTypeBool) {
        this.setState({ truckBool: false })
      }
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
  handleCargoClass (selection) {
    this.setState({ cargoClass: selection }, () => {
      this.handleSearchChange({ target: { value: '' } })
    })
  }
  backToList () {
    this.setState({ currentTruckingPricing: false })
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
      truckBool,
      cargoClass
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
    const { primary, secondary } = theme.colors
    const gradientBackground = gradientGenerator(primary, secondary)
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
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''

    const { expander } = this.state
    const searchResults =
      filteredTruckingPricings.length > 0 ? (
        filteredTruckingPricings.map((tp) => {
          const idenitfierKey = Object.keys(tp).filter(key => key !== 'truckingPricing' && key !== 'countryCode')[0]

          return (
            <AlternativeGreyBox
              wrapperClassName="layout-row flex-40 card_margin_right margin_bottom"
              contentClassName="layout-column flex"
              content={(
                <div
                  className={`flex-100 layout-row layout-align-center-center pointy layout-wrap ${
                    styles.trucking_display_cell
                  }`}
                  key={v4()}
                  onClick={() => this.selectTruckingPricing(tp)}
                >
                  {loadTypeBool
                    ? <div className="flex-70 layout-row layout-align-center-center">
                      <p className="flex-50">{nameToDisplay(tp.truckingPricing.cargo_class)}</p>
                      <p className={`flex-50 ${styles.truck_type_border}`}>{nameToDisplay(tp.truckingPricing.truck_type)}</p>
                    </div>
                    : ''
                  }
                  {idenitfierKey === 'distance' ? (
                    <div className="flex-30 layout-column layout-wrap layout-align-center-center">
                      <p className="flex-90">{capitalize(idenitfierKey)}</p>
                      <p className="flex-90"> {getTruckingPricingKey(tp)}</p>
                    </div>
                  ) : (
                    <div className="flex-100 layout-row layout-wrap layout-align-center-center">
                      <p className="flex-90">{capitalize(idenitfierKey)} {getTruckingPricingKey(tp)}</p>
                    </div>
                  )}

                </div>
              )}
            />

          )
        })
      ) : (
        <div className="flex-100 layout-row layout-align-center-center">
          <p className="flex-none">No truckings available</p>
        </div>
      )
    const backBtn = (
      <div
        className={`flex-20 layout-row pointy layout-align-end-center ${styles.back_button}`}
        onClick={() => this.backToList()}
      >
        <div className="flex-none layout-row layout-align-center-center">
          <i className="flex-none fa fa-angle-left" />
          <p className="flex-none">&nbsp;&nbsp;Back to list</p>
        </div>
      </div>)
    const truckView = currentTruckingPricing ? displayPanel : searchResults
    const truckFilter = loadTypeBool
      ? (<div className="flex-100 layout-row layout-align-space-between-center">
        <div className="flex-90 layout-row layout-align-space-between-center">
          <p className="flex-none">Side Lifter</p>
          <div className="flex-5" />
          <Toggle
            className="flex-none"
            id="unitView"
            name="unitView"
            checked={truckBool}
            onChange={e => this.handleTruckToggle(e)}
          />
          <div className="flex-5" />
          <p className="flex-none">Chassis</p>
        </div>
      </div>) : ''

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start">
        {uploadStatus}
        <div className={`${styles.component_view} flex-80 layout-row layout-align-start-start`}>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            {/* <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_title
              }`}
            >
              <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
                {hub.name}
              </p>
            </div> */}
            <div
              className={`
                flex-85 flex-xs-100 flex-sm-100 layout-row layout-align-center-center
                ${currentTruckingPricing ? 'margin_bottom' : ''}
                ${hubStyles.hub_title}
              `}
              style={gradientBackground}
            >
              <div className={`flex-none layout-row layout-align-space-between-center ${hubStyles.hub_title_content}`}>
                <div className="flex-70 layout-row layout-align-start-center">
                  <h3 className="flex-none"> {hub.name}</h3>
                </div>
                <div className="flex-30 layout-row layout-align-end-center">
                  <div className="flex-none layout-row layout-align-center-center">
                    <h4 className="flex-none" > {renderHubType(hub.hub_type)}</h4>
                  </div>
                  <div className="flex-none layout-row layout-align-center-center" style={{ color: primary }} >
                    {switchIcon(hub.hub_type)}
                  </div>
                </div>
              </div>
            </div>
            <div
              className={`flex-85 layout-row layout-align-end-center ${
                styles.sec_header
              }`}
            >
              { currentTruckingPricing ? backBtn : ''}
            </div>
            <div className="flex-100 layout-row layout-align-space-around-start layout-wrap">
              <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                {truckView}
              </div>
            </div>
          </div>
          {styleTagJSX}
        </div>
        <div className="flex-20 layout-row layout-wrap layout-align-center-start">

          <SideOptionsBox
            header="Filters"
            flexOptions="layout-column flex-100 flex-md-30"
            content={(
              <div>
                <div
                  className="flex-100 layout-row layout-wrap layout-align-center-start input_box_full"
                >
                  <input
                    type="text"
                    value={searchFilter}
                    placeholder="Search Trucking Zones"
                    onChange={e => this.handleSearchChange(e)}
                  />
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    collapsed={!expander.load_type}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('load_type')}
                    headingText="Load Type"
                    faClass="fa fa-ship"
                    content={(
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
                    )}
                  />
                </div>

                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    collapsed={!expander.direction}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('direction')}
                    headingText="Import / Export"
                    faClass="fa fa-star-half-o"
                    content={(
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
                    )}
                  />
                </div>
                {loadTypeBool
                  ? <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                    <CollapsingBar
                      collapsed={!expander.truck_type}
                      theme={theme}
                      handleCollapser={() => this.toggleExpander('truck_type')}
                      headingText="Import / Export"
                      faClass="fa fa-flag"
                      content={truckFilter}
                    />
                  </div> : ''}
                {loadTypeBool
                  ? <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                    <CollapsingBar
                      collapsed={!expander.cargo_class}
                      theme={theme}
                      handleCollapser={() => this.toggleExpander('cargo_class')}
                      headingText="Cargo Class"
                      faClass="fa fa-flag"
                      content={(
                        <NamedSelect
                          placeholder="Cargo Class"
                          className={styles.select}
                          name="cargo_class"
                          value={cargoClass}
                          options={cargoClassOptions}
                          onChange={e => this.handleCargoClass(e)}
                        />
                      )}
                    />
                  </div> : ''}
              </div>
            )}
          />

          <SideOptionsBox
            header="Data manager"
            flexOptions="layout-column flex-100 flex-md-30 margin_bottom"
            content={(
              <div>
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    collapsed={!expander.upload}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('upload')}
                    headingText="Upload Data"
                    faClass="fa fa-cloud-upload"
                    content={(
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
                    )}
                  />
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    collapsed={!expander.download}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('download')}
                    headingText="Download Data"
                    faClass="fa fa-cloud-download"
                    content={(
                      <div>
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
                    )}
                  />
                </div>
              </div>
            )}
          />
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
