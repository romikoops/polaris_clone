import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import ReactTooltip from 'react-tooltip'
import { documentActions } from '../../actions'
import FileUploader from '../FileUploader/FileUploader'
import { RoundButton } from '../RoundButton/RoundButton'
import styles from './Admin.scss'
import { AdminUploadsSuccess } from './Uploads/Success'
import AdminScheduleGenerator from './AdminScheduleGenerator'
import DocumentsDownloader from '../Documents/Downloader'
import { adminSchedules as schedTip } from '../../constants'
import { filters, capitalize } from '../../helpers'
import '../../styles/select-css-custom.css'
import { AdminSearchableRoutes } from './AdminSearchables'
import { Checkbox } from '../Checkbox/Checkbox'

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
      },
      searchResults: []
    }
    this.toggleView = this.toggleView.bind(this)
  }
  componentWillMount () {
    if (this.props.scheduleData && this.props.scheduleData.itineraries) {
      this.prepFilters()
    }
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  componentWillReceiveProps (nextProps) {
    if (
      nextProps.scheduleData &&
      nextProps.scheduleData.itineraries &&
      this.state.searchResults.length < 1
    ) {
      this.prepFilters()
    }
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
  prepFilters () {
    const { itineraries } = this.props.scheduleData
    const tmpFilters = {
      mot: {}
    }
    itineraries.forEach((itin) => {
      tmpFilters.mot[itin.mode_of_transport] = true
    })
    this.setState({
      searchFilters: tmpFilters,
      searchResults: itineraries
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
    if (searchFilters.query && searchFilters.query !== '') {
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
      limit,
      document,
      documentDispatch
    } = this.props

    if (!scheduleData || !hubs) {
      return ''
    }
    const { itineraries } = scheduleData
    const {
      showList, expander, searchFilters, searchResults
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
        <AdminScheduleGenerator theme={theme} itineraries={itineraries} />
      </div>
    )

    const backButton = (
      <RoundButton
        theme={theme}
        text="Back to list"
        size="small"
        iconClass="fa-th-list"
        handleNext={() => this.toggleView()}
        back
      />
    )
    const newButton = (
      <div data-for="tooltipId" data-tip={schedTip.upload_excel}>
        <RoundButton
          theme={theme}
          text="Generate"
          active
          size="small"
          iconClass="fa-plus"
          handleNext={() => this.toggleView()}
        />
        <ReactTooltip id="tooltipId" className={styles.tooltip} effect="solid" />
      </div>
    )
    const sectionStyle =
      theme && theme.colors
        ? { background: theme.colors.secondary, color: 'white' }
        : { background: 'darkslategrey', color: 'white' }
    const typeFilters = Object.keys(searchFilters.mot).map(htk => (
      <div
        className={`${
          styles.action_section
        } flex-100 layout-row layout-align-center-center layout-wrap`}
      >
        <p className="flex-70">{capitalize(htk)}</p>
        <Checkbox
          onChange={() => this.toggleFilterValue('mot', htk)}
          checked={searchFilters.mot[htk]}
          theme={theme}
        />
      </div>
    ))

    const results = this.applyFilters(searchResults)

    const listView = (
      <AdminSearchableRoutes
        itineraries={results}
        theme={theme}
        hubs={hubs}
        hideFilters
        limit={limit || 40}
        heading="Schedules by route:"
        adminDispatch={adminDispatch}
        sideScroll={false}
        handleClick={e => this.viewSchedules(e)}
        showTooltip
        seeAll={false}
      />
    )
    const currView = showList ? listView : genView
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start">
        {uploadStatus}
        <div className={`${styles.component_view} flex-80 layout-row layout-align-start-start`}>
          {currView}
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
              <i className="flex-none fa fa-filter" />
              <h2 className="flex-none offset-5 letter_3 no_m"> Filters </h2>
            </div>
            <div
              className="flex-100 layout-row layout-wrap layout-align-center-start input_box_full"
            >
              <input
                type="text"
                className="flex-100"
                value={searchFilters.query}
                placeholder="Search..."
                onChange={e => this.handleSearchQuery(e)}
              />
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div
                className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                onClick={() => this.toggleExpander('mot')}
              >
                <div className="flex-90 layout-align-start-center layout-row">
                  <i className="flex-none fa fa-ship" />
                  <p className="flex-none">Mode of Transport</p>
                </div>
                <div className={`${styles.expander_icon} flex-10 layout-align-center-center`}>
                  {expander.mot ? (
                    <i className="flex-none fa fa-chevron-up" />
                  ) : (
                    <i className="flex-none fa fa-chevron-down" />
                  )}
                </div>
              </div>
              <div
                className={`${
                  expander.mot ? styles.open_filter : styles.closed_filter
                } flex-100 layout-row layout-wrap layout-align-center-start`}
              >
                {typeFilters}
              </div>
            </div>
          </div>
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
                  <p className="flex-100">Download Schedules Sheet</p>
                  <DocumentsDownloader theme={theme} target="schedules" />
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div
                className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                onClick={() => this.toggleExpander('new')}
              >
                <div className="flex-90 layout-align-start-center layout-row">
                  <i className="flex-none fa fa-plus-circle" />
                  <p className="flex-none">Autogenerate Schedules</p>
                </div>
                <div className={`${styles.expander_icon} flex-10 layout-align-center-center`}>
                  {expander.new ? (
                    <i className="flex-none fa fa-chevron-up" />
                  ) : (
                    <i className="flex-none fa fa-chevron-down" />
                  )}
                </div>
              </div>
              <div
                className={`${
                  expander.new ? styles.open_filter : styles.closed_filter
                } flex-100 layout-row layout-wrap layout-align-center-start`}
              >
                <div
                  className={`${
                    styles.action_section
                  } flex-100 layout-row layout-wrap layout-align-center-center`}
                >
                  {showList ? newButton : backButton}
                </div>
              </div>
            </div>
          </div>
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
    air: PropTypes.arrayOf(PropTypes.schedule),
    train: PropTypes.arrayOf(PropTypes.schedule),
    ocean: PropTypes.arrayOf(PropTypes.schedule),
    detailedItineraries: PropTypes.array.isRequired,
    itineraryIds: PropTypes.Array,
    itineraries: PropTypes.objectOf(PropTypes.any).isRequired
  }),
  document: PropTypes.objectOf(PropTypes.any),
  itineraries: PropTypes.objectOf(PropTypes.any).isRequired,
  adminDispatch: PropTypes.func.isRequired,
  limit: PropTypes.number,
  documentDispatch: PropTypes.objectOf(PropTypes.func)
}

AdminSchedules.defaultProps = {
  theme: null,
  hubs: [],
  scheduleData: null,
  limit: 0,
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

export default connect(mapStateToProps, mapDispatchToProps)(AdminSchedules)
