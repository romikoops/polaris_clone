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
import { TextHeading } from '../TextHeading/TextHeading'
import { adminSchedules as schedTip } from '../../constants'
import '../../styles/select-css-custom.css'
import { AdminSearchableRoutes } from './AdminSearchables'

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
      panelViewer: {}
    }
    this.toggleView = this.toggleView.bind(this)
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
  render () {
    const {
      theme, hubs, scheduleData, adminDispatch, limit, document, documentDispatch
    } = this.props

    if (!scheduleData || !hubs) {
      return ''
    }
    const { itineraries } = scheduleData
    const { showList } = this.state

    const listView = (
      <AdminSearchableRoutes
        itineraries={itineraries}
        theme={theme}
        hubs={hubs}
        limit={limit || 40}
        heading="Schedules by route:"
        adminDispatch={adminDispatch}
        sideScroll={false}
        handleClick={e => this.viewSchedules(e)}
        showTooltip
        seeAll={false}
      />
    )
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
        {uploadStatus}
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}>Excel Uploads</p>
          </div>
          <div
            className={`flex-50 layout-row layout-align-space-between-center layout-wrap ${
              styles.sec_upload
            }`}
          >
            <p className="flex-80">Upload Train Schedules Sheet</p>
            <FileUploader theme={theme} dispatchFn={file => documentDispatch.uploadSchedules(file, 'train')} type="xlsx" text="Train Schedules .xlsx" />
          </div>
          <div
            className={`flex-50 layout-row layout-align-space-between-center layout-wrap ${
              styles.sec_upload
            }`}
          >
            <p className="flex-80">Upload Air Schedules Sheet</p>
            <FileUploader theme={theme} dispatchFn={file => documentDispatch.uploadSchedules(file, 'air')} type="xlsx" text="Air Schedules .xlsx" />
          </div>
          <div
            className={`flex-50 layout-row layout-align-space-between-center layout-wrap ${
              styles.sec_upload
            }`}
          >
            <p className="flex-80">Upload Vessel Schedules Sheet</p>
            <FileUploader theme={theme} dispatchFn={file => documentDispatch.uploadSchedules(file, 'vessel')} type="xlsx" text="Vessel Schedules .xlsx" />
          </div>
          <div
            className={`flex-50 layout-row layout-align-space-between-center layout-wrap ${
              styles.sec_upload
            }`}
          >
            <p className="flex-80">Upload Trucking Schedules Sheet</p>
            <FileUploader theme={theme} dispatchFn={file => documentDispatch.uploadSchedules(file, 'truck')} type="xlsx" text="Truck Schedules .xlsx" />
          </div>
        </div>
        <AdminScheduleGenerator theme={theme} itineraries={itineraries} />
      </div>
    )
    const currView = showList ? listView : genView
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
          text="New Upload"
          active
          size="small"
          iconClass="fa-plus"
          handleNext={() => this.toggleView()}
        />
        <ReactTooltip id="tooltipId" className={styles.tooltip} effect="solid" />
      </div>
    )
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <TextHeading theme={theme} size={1} text="Schedules" />
          {showList ? newButton : backButton}
        </div>
        {currView}
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
