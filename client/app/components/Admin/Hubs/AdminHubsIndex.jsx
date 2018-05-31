import React, { Component } from 'react'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import hubStyles from './index.scss'
import { AdminSearchableHubs } from '../AdminSearchables'
import FileUploader from '../../../components/FileUploader/FileUploader'
import { adminHubs as hubsTip } from '../../../constants'
import { RoundButton } from '../../RoundButton/RoundButton'
import DocumentsDownloader from '../../../components/Documents/Downloader'
import { Checkbox } from '../../Checkbox/Checkbox'
import { capitalize, filters } from '../../../helpers'
import SideOptionsBox from '../SideOptions/SideOptionsBox'

export class AdminHubsIndex extends Component {
  // export function AdminHubsIndex ({
  //   theme,
  //   hubs,
  //   viewHub,
  //   adminDispatch,
  //   toggleNewHub,
  //   documentDispatch
  // }) {
  constructor (props) {
    super(props)
    this.state = {
      searchFilters: {
        hubType: {},
        status: {},
        countries: []
      },
      searchResults: [],
      expander: {}
    }
  }
  componentWillMount () {
    if (this.props.hubs && !this.state.searchResults.length) {
      this.prepFilters()
    }
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
  prepFilters () {
    const { hubs } = this.props
    const tmpFilters = {
      hubType: {},
      countries: {},
      status: {
        active: true,
        inactive: false
      },
      expander: {}
    }
    hubs.forEach((hub) => {
      tmpFilters.hubType[hub.data.hub_type] = true
      tmpFilters.countries[hub.location.country] = true
    })
    this.setState({
      searchFilters: tmpFilters,
      searchResults: hubs
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
    const hubFilterKeys =
      Object.keys(searchFilters.hubType).filter(key => searchFilters.hubType[key])
    const filter1 = array.filter(a => hubFilterKeys.includes(a.data.hub_type))
    let filter2 = []
    const countryKeys =
      Object.keys(searchFilters.countries).filter(key => searchFilters.countries[key])
    if (countryKeys.length > 0) {
      filter2 = filter1.filter(a => countryKeys.includes(a.location.country))
    } else {
      filter2 = filter1
    }
    const statusFilterKeys =
      Object.keys(searchFilters.status).filter(key => searchFilters.status[key])
    const filter3 = filter2.filter(a => statusFilterKeys.includes(a.data.hub_status))
    let filter4
    if (searchFilters.query && searchFilters.query !== '') {
      filter4 = filters.handleSearchChange(
        searchFilters.query,
        ['data.name', 'data.hub_type', 'location.country'],
        filter3
      )
    } else {
      filter4 = filter3
    }
    return filter4
  }
  render () {
    const { searchResults, searchFilters, expander } = this.state
    const {
      theme, viewHub, adminDispatch, toggleNewHub, documentDispatch
    } = this.props
    const hubUrl = '/admin/hubs/process_csv'
    const scUrl = '/admin/service_charges/process_csv'
    const newButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="New Hub"
          active
          handleNext={() => toggleNewHub()}
          iconClass="fa-plus"
        />
      </div>
    )
    if (!this.props.hubs) {
      return ''
    }
    // const sectionStyle =
    //   theme && theme.colors
    //     ? { background: theme.colors.secondary, color: 'white' }
    //     : { background: 'darkslategrey', color: 'white' }
    const typeFilters = Object.keys(searchFilters.hubType).map((htk) => {
      const typeNames = { ocean: 'Port', air: 'Airport', rails: 'Railyard' }
      return (
        <div
          className={`${
            styles.action_section
          } flex-100 layout-row layout-align-center-center layout-wrap`}
        >
          <p className="flex-70">{typeNames[htk]}</p>
          <Checkbox
            onChange={() => this.toggleFilterValue('hubType', htk)}
            checked={searchFilters.hubType[htk]}
            theme={theme}
          />
        </div>
      )
    })
    const statusFilters = Object.keys(searchFilters.status).map(sk => (
      <div
        className={`${
          styles.action_section
        } flex-100 layout-row layout-align-center-center layout-wrap`}
      >
        <p className="flex-70">{capitalize(sk)}</p>
        <Checkbox
          onChange={() => this.toggleFilterValue('status', sk)}
          checked={searchFilters.status[sk]}
          theme={theme}
        />
      </div>
    ))
    const countryFilters = Object.keys(searchFilters.countries).map(country => (
      <div
        className={`${
          styles.action_section
        } flex-100 layout-row layout-align-center-center layout-wrap`}
      >
        <p className="flex-70">{capitalize(country)}</p>
        <Checkbox
          onChange={() => this.toggleFilterValue('countries', country)}
          checked={searchFilters.countries[country]}
          theme={theme}
        />
      </div>
    ))
    const results = this.applyFilters(searchResults)

    return (
      <div className="flex-100 layout-row layout-wrap layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-space-around-start">
          <AdminSearchableHubs
            theme={theme}
            hubs={results}
            adminDispatch={adminDispatch}
            sideScroll={false}
            handleClick={viewHub}
            hideFilters
            seeAll={false}
            icon="fa-info-circle"
            tooltip={hubsTip.manage}
          />
          <div className="flex-20 layout-row layout-wrap layout-align-center-start">
            <div className={`${styles.position_fixed_right}`}>

              <div className={`${styles.filter_panel} flex layout-row`}>
                <SideOptionsBox
                  header="Filter"
                  content={
                    <div>
                      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                        <div
                          className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                          onClick={() => this.toggleExpander('hubType')}
                        >
                          <div className="flex-90 layout-align-start-center layout-row">
                            <i className="flex-none fa fa-ship" />
                            <p className="flex-none">Hub Type</p>
                          </div>
                          <div className={`${hubStyles.expander_icon} flex-10 layout-align-center-center`}>
                            {expander.hubType ? (
                              <i className="flex-none fa fa-chevron-up" />
                            ) : (
                              <i className="flex-none fa fa-chevron-down" />
                            )}
                          </div>
                        </div>
                        <div
                          className={`${
                            expander.hubType ? hubStyles.open_filter : hubStyles.closed_filter
                          } flex-100 layout-row layout-wrap layout-align-center-start`}
                        >
                          {typeFilters}
                        </div>
                      </div>
                      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                        <div
                          className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                          onClick={() => this.toggleExpander('status')}
                        >
                          <div className="flex-90 layout-align-start-center layout-row">
                            <i className="flex-none fa fa-star-half-o" />
                            <p className="flex-none">Status</p>
                          </div>
                          <div className={`${hubStyles.expander_icon} flex-10 layout-align-center-center`}>
                            {expander.status ? (
                              <i className="flex-none fa fa-chevron-up" />
                            ) : (
                              <i className="flex-none fa fa-chevron-down" />
                            )}
                          </div>
                        </div>
                        <div
                          className={`${
                            expander.status ? hubStyles.open_filter : hubStyles.closed_filter
                          } flex-100 layout-row layout-wrap layout-align-center-start`}
                        >
                          {statusFilters}
                        </div>
                      </div>
                      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                        <div
                          className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                          onClick={() => this.toggleExpander('countries')}
                        >
                          <div className="flex-90 layout-align-start-center layout-row">
                            <i className="flex-none fa fa-flag" />
                            <p className="flex-none">Country</p>
                          </div>
                          <div className={`${hubStyles.expander_icon} flex-10 layout-align-center-center`}>
                            {expander.countries ? (
                              <i className="flex-none fa fa-chevron-up" />
                            ) : (
                              <i className="flex-none fa fa-chevron-down" />
                            )}
                          </div>
                        </div>
                        <div
                          className={`${
                            expander.countries ? hubStyles.open_filter : hubStyles.closed_filter
                          } flex-100 layout-row layout-wrap layout-align-center-start`}
                        >
                          {countryFilters}
                        </div>
                      </div>
                    </div>
                  }
                />
              </div>
              <div className="flex layout-row">
                <SideOptionsBox
                  header="Data manager"
                  content={
                    <div>
                      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                        <div
                          className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                          onClick={() => this.toggleExpander('upload')}
                        >
                          <div className="flex-90 layout-align-start-center layout-row">
                            <i className="flex-none fa fa-cloud-upload" />
                            <p className="flex-none">Upload Data</p>
                          </div>
                          <div className={`${hubStyles.expander_icon} flex-10 layout-align-center-center`}>
                            {expander.upload ? (
                              <i className="flex-none fa fa-chevron-up" />
                            ) : (
                              <i className="flex-none fa fa-chevron-down" />
                            )}
                          </div>
                        </div>
                        <div
                          className={`${
                            expander.upload ? hubStyles.open_filter : hubStyles.closed_filter
                          } flex-100 layout-row layout-wrap layout-align-center-start`}
                        >
                          <div
                            className={`${
                              styles.action_section
                            } flex-100 layout-row layout-align-center-center layout-wrap`}
                          >
                            <p className="flex-100 center">Upload Hubs Sheet</p>
                            <FileUploader
                              theme={theme}
                              url={hubUrl}
                              type="xlsx"
                              text="Hub .xlsx"
                              dispatchFn={documentDispatch.uploadHubs}
                            />
                          </div>
                          <div
                            className={`${
                              styles.action_section
                            } flex-100 layout-row layout-align-center-center layout-wrap`}
                          >
                            <p className="flex-100 center">Upload Local Charges Sheet</p>
                            <FileUploader
                              theme={theme}
                              url={scUrl}
                              type="xlsx"
                              text="Hub .xlsx"
                              dispatchFn={documentDispatch.uploadLocalCharges}
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
                          <div className={`${hubStyles.expander_icon} flex-10 layout-align-center-center`}>
                            {expander.download ? (
                              <i className="flex-none fa fa-chevron-up" />
                            ) : (
                              <i className="flex-none fa fa-chevron-down" />
                            )}
                          </div>
                        </div>
                        <div
                          className={`${
                            expander.download ? hubStyles.open_filter : hubStyles.closed_filter
                          } flex-100 layout-row layout-wrap layout-align-center-start`}
                        >
                          <div
                            className={`${
                              styles.action_section
                            } flex-100 layout-row layout-wrap layout-align-center-center`}
                          >
                            <p className="flex-100 center">Download Hubs Sheet</p>
                            <DocumentsDownloader theme={theme} target="hubs" />
                          </div>
                          <div
                            className={`${
                              styles.action_section
                            } flex-100 layout-row layout-wrap layout-align-center-center`}
                          >
                            <p className="flex-100 center">Download Ocean Local Charges Sheet</p>
                            <DocumentsDownloader
                              theme={theme}
                              target="local_charges"
                              options={{ mot: 'ocean' }}
                            />
                          </div>
                          <div
                            className={`${
                              styles.action_section
                            } flex-100 layout-row layout-wrap layout-align-center-center`}
                          >
                            <p className="flex-100 center">Download Air Local Charges Sheet</p>
                            <DocumentsDownloader
                              theme={theme}
                              target="local_charges"
                              options={{ mot: 'air' }}
                            />
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
                            <p className="flex-none">Create New Hub</p>
                          </div>
                          <div className={`${hubStyles.expander_icon} flex-10 layout-align-center-center`}>
                            {expander.new ? (
                              <i className="flex-none fa fa-chevron-up" />
                            ) : (
                              <i className="flex-none fa fa-chevron-down" />
                            )}
                          </div>
                        </div>
                        <div
                          className={`${
                            expander.new ? hubStyles.open_filter : hubStyles.closed_filter
                          } flex-100 layout-row layout-wrap layout-align-center-start`}
                        >
                          <div
                            className={`${
                              styles.action_section
                            } flex-100 layout-row layout-wrap layout-align-center-center`}
                          >
                            {newButton}
                          </div>
                        </div>
                      </div>
                    </div>
                  }
                />
              </div>
            </div>
            {/* <div
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

          </div> */}
          </div>
        </div>
      </div>

    )
  }
}

AdminHubsIndex.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  viewHub: PropTypes.func.isRequired,
  toggleNewHub: PropTypes.func.isRequired,
  adminDispatch: PropTypes.shape({
    getHub: PropTypes.func
  }).isRequired,
  documentDispatch: PropTypes.shape({
    closeViewer: PropTypes.func,
    uploadHubs: PropTypes.func
  }).isRequired
}

AdminHubsIndex.defaultProps = {
  theme: null,
  hubs: []
}

export default AdminHubsIndex
