import React, { Component } from 'react'
import PropTypes from 'prop-types'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import ReactTable from 'react-table'
import 'react-table/react-table.css'

import { documentActions } from '../../../../actions'
import { AdminUploadsSuccess } from './../../Uploads/Success'
import FileUploader from '../../../FileUploader/FileUploader'
import { RoundButton } from '../../../RoundButton/RoundButton'
import styles from '../../Admin.scss'
import { AdminTripPanel } from '../../AdminTripPanel'
import AdminScheduleGenerator from '../../AdminScheduleGenerator/index'
import TextHeading from '../../../TextHeading/TextHeading'
import DocumentsDownloader from '../../../Documents/Downloader'
import { filters } from '../../../../helpers'
import { moment } from '../../../../constants'
import SideOptionsBox from '../../SideOptions/SideOptionsBox'
import CollapsingBar from '../../../CollapsingBar/CollapsingBar'
import GenericError from '../../../ErrorHandling/Generic'

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
      const result1 = a[prop] < b[prop] ? -1 : 1

      return result1 * sortOrder
    }
  }
  constructor (props) {
    super(props)
    this.state = {
      showList: true,
      expander: {},
      panelViewer: {},
      searchResults: []
    }
    this.toggleView = this.toggleView.bind(this)
    this.toggleShowPanel = this.toggleShowPanel.bind(this)
    this.getItinerariesForHub = this.getItinerariesForHub.bind(this)
    this.closeSuccessDialog = this.closeSuccessDialog.bind(this)
  }
  componentWillMount () {
    if (
      this.props.scheduleData &&
      this.props.scheduleData.schedules &&
      !this.state.searchResults.length
    ) {
      this.prepFilters()
    }
    this.props.setCurrentUrl('/admin/schedules')
  }
  componentDidMount () {
    window.scrollTo(0, 0)
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
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }
  toggleFilterValue (key) {
    const sort = {
      start_date: false,
      end_date: false,
      closing_date: false
    }
    sort[key] = true
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        sort
      }
    })
  }
  prepFilters () {
    const { schedules } = this.props.scheduleData
    const tmpFilters = {
      sort: {
        start_date: true,
        end_date: false,
        closing_date: false
      },
      query: ''
    }
    this.setState({
      searchFilters: tmpFilters,
      searchResults: schedules
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
    const sortKey = Object.keys(searchFilters.sort).filter(key => searchFilters.sort[key])[0]

    let filter1
    if (searchFilters.query && searchFilters.query !== '') {
      filter1 = filters.handleSearchChange(searchFilters.query, ['voyage_code', 'vessel'], array)
    } else {
      filter1 = array
    }

    const filter2 = filter1.sort((a, b) => new Date(a[sortKey]) - new Date(b[sortKey]))

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
    const {
      panelViewer, showList, expander, searchResults, searchFilters
    } = this.state
    if (!scheduleData || !hubs) {
      return ''
    }
    const uploadStatus = document.viewer ? (
      <AdminUploadsSuccess
        theme={theme}
        data={document.results}
        closeDialog={this.closeSuccessDialog}
      />
    ) : (
      ''
    )
    const columns = [
      {
        Header: 'Closing Date',
        accessor: 'closing_date',
        Cell: row => (
          moment(row.value).format('ll')
        )
      },
      {
        Header: 'ETD',
        accessor: 'start_date',
        Cell: row => (
          moment(row.value).format('ll')
        )
      },
      {
        Header: 'ETA',
        accessor: 'end_date',
        Cell: row => (
          moment(row.value).format('ll')
        )
      },
      {
        Header: 'Voyage Code',
        accessor: 'voyage_code'
      },
      {
        Header: 'Vessel Name',
        accessor: 'vessel'
      }
    ]
    const { itinerary, itineraryLayovers, schedules } = scheduleData
    const tripArr = []
    const slimit = limit || 100

    const results = this.applyFilters(searchResults)
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
      <div className="layout-row flex-95 layout-wrap layout-align-start-center">
        <AdminScheduleGenerator theme={theme} itinerary={itinerary} />
      </div>
    )

    const listView = (
      <div className="layout-row flex-95 layout-wrap layout-align-start-center">
        <ReactTable
          className="flex-100 height_100"
          data={schedules}
          columns={columns}
          defaultSorted={[
            {
              id: 'closing_date',
              desc: true
            }
          ]}
          defaultPageSize={20}
        />
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
        className={`flex-100 layout-row layout-wrap layout-align-center-center ${
          styles.sec_upload
        }`}
      >
        <p className="flex-80">Create/ Upload Schedules</p>
        <RoundButton
          theme={theme}
          text="New"
          active
          size="small"
          iconClass="fa-plus"
          handleNext={this.toggleView}
        />
        <ReactTooltip id="tooltipId" className={styles.tooltip} effect="solid" />
      </div>
    )

    return (
      <GenericError theme={theme}>
        <div className="flex-100 layout-row layout-wrap layout-align-space-around-start extra_padding_left padding_top">
          {uploadStatus}
          <div className="flex-80 layout-row layout-align-start-start layout-wrap">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
            >
              <TextHeading theme={theme} size={1} text={`Schedules: ${itinerary.name}`} />
            </div>
            {showList ? listView : genView}
          </div>
          <div className=" flex-20 layout-row layout-wrap layout-align-center-start">
            <SideOptionsBox
              header="Filters"
              flexOptions="flex-100"
              content={(
                <div>
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
                </div>
              )}
            />
            <SideOptionsBox
              header="Data manager"
              flexOptions="flex-100"
              content={(
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    collapsed={!expander.upload}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('upload')}
                    showArrow
                    text="Upload Data"
                    faClass="fa fa-cloud-upload"
                    content={(
                      <div>
                        <div
                          className={`${
                            styles.action_section
                          } flex-100 layout-row layout-align-center-center layout-wrap`}
                        >
                          <p className="flex-80">{`Upload ${itinerary.name} Schedules Sheet`}</p>
                          <FileUploader
                            theme={theme}
                            dispatchFn={file =>
                              documentDispatch.uploadItinerarySchedules(file, itinerary.id)
                            }
                            type="xlsx"
                            text="Train Schedules .xlsx"
                          />
                        </div>
                      </div>
                    )}
                  />
                  <CollapsingBar
                    collapsed={!expander.download}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('download')}
                    showArrow
                    text="Download Data"
                    faClass="fa fa-cloud-download"
                    content={(
                      <div>
                        <div
                          className={`${
                            styles.action_section
                          } flex-100 layout-row layout-wrap layout-align-center-center`}
                        >
                          <p className="flex-80">Download Schedules Sheet</p>
                          <DocumentsDownloader
                            theme={theme}
                            target="schedules"
                            options={{ itinerary_id: itinerary.id }}
                          />
                        </div>
                      </div>
                    )}
                  />
                  <CollapsingBar
                    collapsed={!expander.new}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('new')}
                    showArrow
                    text="Generate Schedules"
                    faClass="fa fa-plus-circle"
                    content={(
                      <div
                        className={`${
                          styles.action_section
                        } flex-100 layout-row layout-wrap layout-align-center-center`}
                      >
                        {showList ? newButton : backButton}
                      </div>
                    )}
                  />
                </div>
              )}
            />
          </div>
        </div>
      </GenericError>
    )
  }
}
AdminSchedulesRoute.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  scheduleData: PropTypes.shape({
    routes: PropTypes.arrayOf(PropTypes.route),
    schedules: PropTypes.arrayOf(PropTypes.schedule),
    detailedItineraries: PropTypes.array.isRequired,
    itineraryIds: PropTypes.Array,
    itineraries: PropTypes.objectOf(PropTypes.any).isRequired
  }),
  itineraries: PropTypes.objectOf(PropTypes.any).isRequired,
  adminDispatch: PropTypes.func.isRequired,
  setCurrentUrl: PropTypes.func.isRequired,
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
