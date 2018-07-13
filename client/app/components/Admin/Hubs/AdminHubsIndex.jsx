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
import { NamedSelect } from '../../NamedSelect/NamedSelect'

export class AdminHubsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      searchFilters: {
        hubType: {
          air: true,
          ocean: true
        },
        status: {
          active: true,
          inactive: false
        },
        countries: []
      },
      expander: {},
      page: 1
    }
    this.nextPage = this.nextPage.bind(this)
    this.handleFilters = this.handleFilters.bind(this)
    this.handlePage = this.handlePage.bind(this)
    this.prevPage = this.prevPage.bind(this)
    this.handleInput = this.handleInput.bind(this)
  }
  // componentWillMount () {
  //   if (this.props.hubs && !this.state.searchResults.length) {
  //     this.prepFilters()
  //   }
  // }

  // componentWillReceiveProps (nextProps) {
  //   if (nextProps.hubs.length) {
  //     this.prepFilters(nextProps.hubs)
  //   }
  // }
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
    }, () => this.handleFilters())
  }
  handleInput (selection) {
    delete selection.name
    // debugger
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        countries: Object.values(selection)
      }
    }, () => this.handleFilters())
  }
  // prepFilters (nextHubs) {
  //   const { hubs } = this.props
  //   const filterablehubs = nextHubs || hubs
  //   const tmpFilters = {
  //     hubType: {},
  //     countries: {},
  //     status: {
  //       active: true,
  //       inactive: false
  //     },
  //     expander: {}
  //   }
  //   filterablehubs.forEach((hub) => {
  //     tmpFilters.hubType[hub.data.hub_type] = true
  //     tmpFilters.countries[hub.location.country] = true
  //   })

  //   this.setState({
  //     searchFilters: tmpFilters,
  //     searchResults: filterablehubs.slice()
  //   })
  // }
  handlePage (direction, hubType, country, status) {
    if (!hubType && !country && !status) {
      this.setState((prevState) => {
        this.props.getHubsFromPage(prevState.page + (1 * direction))

        return { page: prevState.page + (1 * direction) }
      })
    } else {
      this.handleFilters()
    }
  }
  handleFilters () {
    const { searchFilters } = this.state

    const hubFilterKeys =
      Object.keys(searchFilters.hubType).filter(key => searchFilters.hubType[key])
    const countryKeys =
      searchFilters.countries.map(selection => selection.value)
    const statusFilterKeys =
      Object.keys(searchFilters.status).filter(key => searchFilters.status[key])

    this.setState((prevState) => {
      this.props.getHubsFromPage(prevState.page, hubFilterKeys, countryKeys, statusFilterKeys)

      return { page: prevState.page }
    })
  }
  nextPage () {
    this.handlePage(1)
  }
  prevPage () {
    this.handlePage(-1)
  }
  doNothing () {
    console.log(this.state.page)
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
    const { searchFilters, expander } = this.state
    const {
      theme, viewHub, toggleNewHub, documentDispatch, hubs, countries
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
    const loadCountries = countries ? countries.map(country => ({
      label: country.name,
      value: country.id
    })) : []

    const namedCountries = (
      <NamedSelect
        className="flex-100"
        multi
        name="country_select"
        value={searchFilters.countries}
        autoload={false}
        options={loadCountries}
        onChange={e => this.handleInput(e)}
      />
    )
    // const countryFilters = countries.map(country => (
    //   <div
    //     className={`${
    //       styles.action_section
    //     } flex-100 layout-row layout-align-center-center layout-wrap`}
    //   >
    //     <p className="flex-70">{country.name}</p>
    //     <Checkbox
    //       onChange={() => this.toggleFilterValue('countries', country.id)}
    //       checked={searchFilters.countries[country.id]}
    //       theme={theme}
    //     />
    //   </div>
    // ))

    const hubsArr = hubs.map(hub => (
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
            <div className="layout-row flex-100 layout-align-start-center header_buffer layout-wrap">
              <div className="layout-row flex-95 layout-align-space-around-start layout-wrap">
                {hubsArr}
              </div>

              <div className="flex-95 layout-row layout-align-center-center margin_bottom">
                <div
                  className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${this.state.page === 1 ? styles.disabled : ''}
                    `}
                  onClick={this.prevPage}
                >
                  {/* style={this.state.page === 1 ? { display: 'none' } : {}} */}
                  <i className="fa fa-chevron-left" />
                  <p>&nbsp;&nbsp;&nbsp;&nbsp;Back</p>
                </div>
                {}
                <p>{this.state.page}</p>
                <div
                  className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${hubsArr.length < 12 ? styles.disabled : ''}
                    `}
                  onClick={this.nextPage}
                >
                  <p>Next&nbsp;&nbsp;&nbsp;&nbsp;</p>
                  <i className="fa fa-chevron-right" />
                </div>
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
                        minHeight="400px"
                        handleCollapser={() => this.toggleExpander('countries')}
                        headingText="Country"
                        faClass="fa fa-flag"
                        content={namedCountries}
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
  countries: PropTypes.arrayOf(PropTypes.any),
  toggleNewHub: PropTypes.func.isRequired,
  documentDispatch: PropTypes.shape({
    closeViewer: PropTypes.func,
    uploadHubs: PropTypes.func
  }).isRequired
}

AdminHubsIndex.defaultProps = {
  theme: null,
  hubs: [],
  countries: []
}

export default AdminHubsIndex
