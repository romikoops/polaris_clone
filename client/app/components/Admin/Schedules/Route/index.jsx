import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Select from 'react-select'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'node-uuid'
import styled from 'styled-components'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { documentActions } from '../../../../actions'
import { AdminUploadsSuccess } from './../../Uploads/Success'
import FileUploader from '../../../FileUploader/FileUploader'
import { RoundButton } from '../../../RoundButton/RoundButton'
import styles from '../../Admin.scss'
import { AdminTripPanel } from '../../AdminTripPanel'
import AdminScheduleGenerator from '../../AdminScheduleGenerator'
import { TextHeading } from '../../../TextHeading/TextHeading'
// import { adminSchedulesRoute as schedTip } from '../../../../constants'
import '../../../../styles/select-css-custom.css'

class AdminSchedulesRoute extends Component {
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
      filters: {
        hub: false,
        mot: false,
        sort: false
      },
      sortFilter: { value: false, label: false },
      panelViewer: {}
    }
    this.toggleView = this.toggleView.bind(this)
    this.setSortFilter = this.setSortFilter.bind(this)
    this.toggleShowPanel = this.toggleShowPanel.bind(this)
    this.getItinerariesForHub = this.getItinerariesForHub.bind(this)
    this.closeSuccessDialog = this.closeSuccessDialog.bind(this)
  }

  setSortFilter (sorter) {
    if (!sorter) {
      this.setState({
        sortFilter: { value: false, label: false },
        filters: {
          ...this.state.filters,
          sort: false
        }
      })
    } else {
      this.setState({
        sortFilter: sorter,
        filters: {
          ...this.state.filters,
          sort: true
        }
      })
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
  closeSuccessDialog () {
    const { documentDispatch } = this.props
    documentDispatch.closeViewer()
  }
  toggleShowPanel (id) {
    if (!this.state.panelViewer[id]) {
      this.props.adminDispatch.getLayovers(id, 'schedules')
    }
    this.setState({
      panelViewer: {
        ...this.state.panelViewer,
        [id]: !this.state.panelViewer[id]
      }
    })
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
    const {
      filters, sortFilter, panelViewer, showList
    } = this.state
    if (!scheduleData || !hubs) {
      return ''
    }

    const filterSortOptions = [
      { value: 'start_date', label: 'ETA' },
      { value: 'end_date', label: 'ETD' }
    ]
    const uploadStatus = document.viewer ? (
      <AdminUploadsSuccess
        theme={theme}
        data={document.results}
        closeDialog={this.closeSuccessDialog}
      />
    ) : (
      ''
    )
    const { itinerary, schedules, itineraryLayovers } = scheduleData
    const tripArr = []
    const slimit = limit || 10

    if (filters.sort) {
      schedules.sort(AdminSchedulesRoute.dynamicSort(sortFilter.value))
    }
    const results = schedules

    console.log(results)
    results.forEach((trip, i) => {
      if (i < slimit) {
        tripArr.push(<AdminTripPanel
          key={v4()}
          trip={trip}
          showPanel={panelViewer[trip.id]}
          toggleShowPanel={this.toggleShowPanel}
          layovers={itineraryLayovers}
          adminDispatch={adminDispatch}
          itinerary={itinerary}
          hubs={hubs}
          theme={theme}
        />)
      }
    })
    // const uploadUrl = `/admin/schedules/overwrite/${itinerary.id}`
    const genView = (
      <div className="layout-row flex-100 layout-wrap layout-align-start-center">
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
            <p className="flex-80">{`Upload ${itinerary.name} Schedules Sheet`}</p>
            <FileUploader
              theme={theme}
              dispatchFn={file => documentDispatch.uploadItinerarySchedules(file, itinerary.id)}
              type="xlsx"
              text="Train Schedules .xlsx"
            />
          </div>
        </div>
        <AdminScheduleGenerator theme={theme} itinerary={itinerary} />
      </div>
    )

    const StyledSelect = styled(Select)`
      .Select-control {
        background-color: #f9f9f9;
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2 !important;
      }
      .Select-menu-outer {
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2;
      }
      .Select-value {
        background-color: #f9f9f9;
        border: 1px solid #f2f2f2;
      }
      .Select-option {
        background-color: #f9f9f9;
      }
    `
    const listView = (
      <div className="layout-row flex-100 layout-wrap layout-align-start-center">
        <div
          className="flex-100 layout-row layout-align-start-center"
          style={{ marginBottom: '25px' }}
        >
          <div className="flex-25 layout-row layout-align-start-center">
            <StyledSelect
              name="sort-filter"
              placeholder="Sort by: Time"
              className={`${styles.select}`}
              value={this.state.sortFilter}
              options={filterSortOptions}
              onChange={this.setSortFilter}
            />
          </div>
        </div>
        {tripArr}
      </div>
    )

    const backButton = (
      <RoundButton
        theme={theme}
        text="Back to list"
        size="small"
        iconClass="fa-th-list"
        handleNext={this.toggleView}
        back
      />
    )
    const newButton = (
      <div
        data-for="tooltipId"
        // data-tip={schedTip.upload_excel}
      >
        <RoundButton
          theme={theme}
          text="New Upload"
          active
          size="small"
          iconClass="fa-plus"
          handleNext={this.toggleView}
        />
        <ReactTooltip id="tooltipId" className={styles.tooltip} effect="solid" />
      </div>
    )
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        {uploadStatus}
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <TextHeading theme={theme} size={1} text="Schedules" />
          {showList ? newButton : backButton}
        </div>
        {showList ? listView : genView}
      </div>
    )
  }
}
AdminSchedulesRoute.propTypes = {
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
  itineraries: PropTypes.objectOf(PropTypes.any).isRequired,
  adminDispatch: PropTypes.func.isRequired,
  limit: PropTypes.number,
  document: PropTypes.objectOf(PropTypes.any),
  documentDispatch: PropTypes.objectOf(PropTypes.func)
}

AdminSchedulesRoute.defaultProps = {
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

export default connect(mapStateToProps, mapDispatchToProps)(AdminSchedulesRoute)
