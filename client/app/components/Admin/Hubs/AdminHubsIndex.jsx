import React, { Component } from 'react'
import { v4 } from 'uuid'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import FileUploader from '../../../components/FileUploader/FileUploader'
import { adminClicked as clickTip } from '../../../constants'
import { RoundButton } from '../../RoundButton/RoundButton'
import DocumentsDownloader from '../../../components/Documents/Downloader'
import { Checkbox } from '../../Checkbox/Checkbox'
import { capitalize, filters } from '../../../helpers'
import { AdminHubTile } from './AdminHubTile'
import SideOptionsBox from '../SideOptions/SideOptionsBox'
import CollapsingBar from '../../CollapsingBar/CollapsingBar'

export class AdminHubsIndex extends Component {
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

  componentWillReceiveProps (nextProps) {
    if (nextProps.hubs.length) {
      this.prepFilters(nextProps.hubs)
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
  prepFilters (nextHubs) {
    const { hubs } = this.props
    const filterablehubs = nextHubs || hubs
    const tmpFilters = {
      hubType: {},
      countries: {},
      status: {
        active: true,
        inactive: false
      },
      expander: {}
    }
    filterablehubs.forEach((hub) => {
      tmpFilters.hubType[hub.data.hub_type] = true
      tmpFilters.countries[hub.location.country] = true
    })

    this.setState({
      searchFilters: tmpFilters,
      searchResults: filterablehubs.slice()
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
      theme, viewHub, toggleNewHub, documentDispatch
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

    const hubsArr = results.map(hub => (
      <AdminHubTile
        key={v4()}
        hub={hub}
        theme={theme}
        handleClick={viewHub}
        tooltip={clickTip.related}
        showTooltip
      />
    ))

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding_left">
        <div className="flex-100 layout-row layout-align-space-between-start">
          <div className="layout-row flex-80 flex-sm-100">
            <div className="layout-row flex-100 layout-align-start-center header_buffer">
              <div className="layout-row flex-100 layout-align-space-around-start layout-wrap">
                {hubsArr}
              </div>
            </div>
          </div>
          <div className="flex-20 hide-sm hide-xs layout-row layout-wrap layout-align-end-end">
            <div className={`${styles.position_fixed_right}`}>

              <div className={`${styles.filter_panel} flex layout-row`}>
                <SideOptionsBox
                  header="Filter"
                  content={(
                    <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                      <CollapsingBar
                        collapsed={!expander.hubType}
                        theme={theme}
                        handleCollapser={() => this.toggleExpander('hubType')}
                        headingText="Hub Type"
                        faClass="fa fa-ship"
                        content={typeFilters}
                      />
                      <CollapsingBar
                        collapsed={!expander.status}
                        theme={theme}
                        handleCollapser={() => this.toggleExpander('status')}
                        headingText="Status"
                        faClass="fa fa-ship"
                        content={statusFilters}
                      />
                      <CollapsingBar
                        collapsed={!expander.countries}
                        theme={theme}
                        handleCollapser={() => this.toggleExpander('countries')}
                        headingText="Country"
                        faClass="fa fa-flag"
                        content={countryFilters}
                      />
                    </div>
                  )}
                />
              </div>
              <div className="flex layout-row">
                <SideOptionsBox
                  header="Data manager"
                  content={(
                    <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                      <CollapsingBar
                        collapsed={!expander.upload}
                        theme={theme}
                        handleCollapser={() => this.toggleExpander('upload')}
                        headingText="Upload Data"
                        faClass="fa fa-cloud-upload"
                        content={(
                          <div>
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
                        )}
                      />
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
                        )}
                      />
                      <CollapsingBar
                        collapsed={!expander.new}
                        theme={theme}
                        handleCollapser={() => this.toggleExpander('new')}
                        headingText="Create New Hub"
                        faClass="fa fa-plus-circle"
                        content={(
                          <div
                            className={`${
                              styles.action_section
                            } flex-100 layout-row layout-wrap layout-align-center-center`}
                          >
                            {newButton}
                          </div>
                        )}
                      />
                    </div>
                  )}
                />
              </div>
            </div>
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
