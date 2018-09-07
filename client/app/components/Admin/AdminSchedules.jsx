import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { documentActions } from '../../actions'
import FileUploader from '../FileUploader/FileUploader'
import styles from './Admin.scss'
import { AdminUploadsSuccess } from './Uploads/Success'
import AdminScheduleGenerator from './AdminScheduleGenerator'
import DocumentsDownloader from '../Documents/Downloader'
import { filters, capitalize } from '../../helpers'
import '../../styles/select-css-custom.css'
import SideOptionsBox from './SideOptions/SideOptionsBox'
import CollapsingBar from '../CollapsingBar/CollapsingBar'
import CardRoutesIndex from './CardRouteIndex'
import { WorldMap } from './DashboardMap/WorldMap'
import Tab from '../Tabs/Tab'
import Tabs from '../Tabs/Tabs'

class AdminSchedules extends Component {
  static dynamicSort (property) {
    let sortOrder = 1
    let prop
    if (property[0] === '-') {
      sortOrder = -1
      prop = property.substr(1)
    } else {
      prop = property
    }

    return (a, b) => {
      const result1 = a[prop] < b[prop] ? -1 : a[prop] > b[prop]
      const result2 = result1 ? 1 : 0

      return result2 * sortOrder
    }
  }
  constructor (props) {
    super(props)
    this.state = {
      showList: true,
      panelViewer: {},
      expander: {},
      searchFilters: {
        mot: {}
      }
    }
    this.toggleView = this.toggleView.bind(this)
  }

  componentDidMount () {
    window.scrollTo(0, 0)
    this.props.setCurrentUrl(this.props.match.url)
  }

  getItinerary (sched) {
    return this.props.scheduleData.itineraries.filter(x => x.id === sched.itinerary_id)[0]
  }
  getItinerariesForHub (hub) {
    const filteredItineraries = this.props.scheduleData.detailedItineraries.filter((itinerary) => {
      if (!itinerary) {
        return false
      }

      return itinerary.origin_hub_id === hub.id || itinerary.destination_hub_id === hub.id
    })

    return filteredItineraries.map(x => x.id)
  }
  toggleView () {
    this.setState({ showList: !this.state.showList })
  }
  toggleShowPanel (id) {
    if (!this.state.panelViewer[id]) {
      this.props.adminDispatch.getLayovers(id)
    }
    this.setState({
      panelViewer: {
        ...this.state.panelViewer,
        [id]: !this.state.panelViewer[id]
      }
    })
  }
  closeSuccessDialog () {
    const { documentDispatch } = this.props
    documentDispatch.closeViewer()
  }
  viewSchedules (itinerary) {
    const { adminDispatch } = this.props
    adminDispatch.loadItinerarySchedules(itinerary.id, true)
  }
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }

  toggleFilterValue (target, key) {
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        [target]: {
          ...this.state.searchFilters[target],
          [key]: !this.state.searchFilters[target][key]
        }
      }
    })
  }
  handleSearchQuery (e) {
    const { value } = e.target
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        query: value
      }
    })
  }
  applyFilters (array) {
    const { searchFilters } = this.state
    const motKeys = Object.keys(searchFilters.mot).filter(key => searchFilters.mot[key])
    const filter1 = array.filter(a => motKeys.includes(a.mode_of_transport))
    let filter2
    if (searchFilters.query) {
      filter2 = filters.handleSearchChange(
        searchFilters.query,
        ['name', 'mode_of_transport'],
        filter1
      )
    } else {
      filter2 = filter1
    }

    return filter2
  }
  render () {
    const {
      theme,
      hubs,
      scheduleData,
      adminDispatch,
      document,
      documentDispatch,
      scope
    } = this.props

    if (!scheduleData || !hubs) {
      return ''
    }
    const { itineraries, mapData } = scheduleData
    const {
      showList, expander
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
    const genView = (
      <div className="layout-row flex-100 layout-wrap layout-align-start-center">
        <AdminScheduleGenerator
          theme={theme}
          itineraries={itineraries}
          toggleNew={this.toggleView}
        />
      </div>
    )

    const modesOfTransport = scope.modes_of_transport
    const modeOfTransportNames = Object.keys(modesOfTransport).filter(modeOfTransportName =>
      Object.values(modesOfTransport[modeOfTransportName]).some(bool => bool))

    const sideMenuNodes = [
      (<SideOptionsBox
        header="Data manager"
        content={(
          <div className="flex-100 layout-row layout-wrap layout-align-center-start">
            <CollapsingBar
              showArrow
              collapsed={!expander.upload}
              theme={theme}
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
                    <p className="flex-80">Upload Air Schedules Sheet</p>
                    <FileUploader
                      theme={theme}
                      dispatchFn={file => documentDispatch.uploadSchedules(file, 'air')}
                      type="xlsx"
                      text="Air Schedules .xlsx"
                    />
                  </div>
                  <div
                    className={`${
                      styles.action_section
                    } flex-100 layout-row layout-align-center-center layout-wrap`}
                  >
                    <p className="flex-80">Upload Train Schedules Sheet</p>
                    <FileUploader
                      theme={theme}
                      dispatchFn={file => documentDispatch.uploadSchedules(file, 'train')}
                      type="xlsx"
                      text="Train Schedules .xlsx"
                    />
                  </div>
                  <div
                    className={`${
                      styles.action_section
                    } flex-100 layout-row layout-align-center-center layout-wrap`}
                  >
                    <p className="flex-80">Upload Vessel Schedules Sheet</p>
                    <FileUploader
                      theme={theme}
                      dispatchFn={file => documentDispatch.uploadSchedules(file, 'vessel')}
                      type="xlsx"
                      text="Vessel Schedules .xlsx"
                    />
                  </div>
                  <div
                    className={`${
                      styles.action_section
                    } flex-100 layout-row layout-align-center-center layout-wrap`}
                  >
                    <p className="flex-80">Upload Trucking Schedules Sheet</p>
                    <FileUploader
                      theme={theme}
                      dispatchFn={file => documentDispatch.uploadSchedules(file, 'truck')}
                      type="xlsx"
                      text="Truck Schedules .xlsx"
                    />
                  </div>
                </div>
              )}
            />
            <CollapsingBar
              showArrow
              collapsed={!expander.download}
              theme={theme}
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
                    <p className="flex-100">Download Schedules Sheet</p>
                    <DocumentsDownloader theme={theme} target="schedules" />
                  </div>
                </div>
              )}
            />
          </div>
        )}
      />)
    ]
    const motTabs = modeOfTransportNames.sort().map(mot => (<Tab
      tabTitle={capitalize(mot)}
      theme={theme}
      mot={mot}
    >
      <CardRoutesIndex
        itineraries={itineraries.filter(itin => itin.mode_of_transport === mot)}
        theme={theme}
        scope={scope}
        mot={mot}
        newText="New Schedule/s"
        adminDispatch={adminDispatch}
        toggleNew={this.toggleView}
        sideMenuNodes={sideMenuNodes}
        handleClick={id => adminDispatch.loadItinerarySchedules(id, true)}
      />
    </Tab>))
    motTabs.push(<Tab
      tabTitle="Map"
      theme={theme}
      icon="fa fa-map flex-none"
    >
      <div className="flex-100 layout-row layout-align-center-start header_buffer">
        <WorldMap
          itineraries={itineraries}
          theme={theme}
          mapData={mapData}

        />
      </div>
    </Tab>)
    const listView = (
      <div className="flex-100 layout-row layout-align-center-start header_buffer">
        <Tabs
          wrapperTabs="layout-row flex-45 flex-sm-40 flex-xs-80"
        >
          {motTabs}

        </Tabs>
      </div>
    )
    const currView = showList ? listView : genView

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start extra_padding_left">
        {uploadStatus}
        <div className={`${styles.component_view} flex layout-row layout-align-start-start`}>
          {currView}
        </div>
      </div>
    )
  }
}
AdminSchedules.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  scheduleData: PropTypes.shape({
    routes: PropTypes.arrayOf(PropTypes.route),
    mapData: PropTypes.arrayOf(PropTypes.object),
    detailedItineraries: PropTypes.array.isRequired,
    itineraryIds: PropTypes.Array,
    itineraries: PropTypes.objectOf(PropTypes.any).isRequired
  }),
  document: PropTypes.objectOf(PropTypes.any),
  itineraries: PropTypes.objectOf(PropTypes.any).isRequired,
  adminDispatch: PropTypes.func.isRequired,
  setCurrentUrl: PropTypes.func.isRequired,
  documentDispatch: PropTypes.objectOf(PropTypes.func),
  scope: PropTypes.objectOf(PropTypes.any)
}

AdminSchedules.defaultProps = {
  theme: null,
  hubs: [],
  scheduleData: null,
  document: {},
  documentDispatch: {},
  scope: {}
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

export default connect(mapStateToProps, mapDispatchToProps)(AdminSchedules)
