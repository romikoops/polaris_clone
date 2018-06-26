import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { AdminSearchableHubs } from './AdminSearchables'
import styles from './Admin.scss'
import { Checkbox } from '../Checkbox/Checkbox'
import { capitalize, filters } from '../../helpers'

export class AdminTruckingIndex extends Component {
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
  componentDidMount () {
    const { truckingNexuses, loading, adminDispatch } = this.props
    if (!truckingNexuses && !loading) {
      adminDispatch.getTrucking(false)
    }
    window.scrollTo(0, 0)
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
    const hubFilterKeys = Object.keys(searchFilters.hubType)
      .filter(key => searchFilters.hubType[key])
    const filter1 = array.filter(a => hubFilterKeys.includes(a.data.hub_type))
    let filter2 = []
    const countryKeys = Object.keys(searchFilters.countries)
      .filter(key => searchFilters.countries[key])
    if (countryKeys.length > 0) {
      filter2 = filter1.filter(a => countryKeys.includes(a.location.country))
    } else {
      filter2 = filter1
    }
    const statusFilterKeys = Object.keys(searchFilters.status)
      .filter(key => searchFilters.status[key])
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
    const {
      theme, viewTrucking, truckingNexuses, adminDispatch
    } = this.props
    const { searchResults, searchFilters, expander } = this.state
    if (!truckingNexuses) {
      return ''
    }
    const sectionStyle =
      theme && theme.colors
        ? { background: theme.colors.secondary, color: 'white' }
        : { background: 'darkslategrey', color: 'white' }
    const typeFilters = Object.keys(searchFilters.hubType).map((htk) => {
      const typeNames = { ocean: 'Port', air: 'Airport', rails: 'Railyard' }

      return (
        <div
          className={`
            ${styles.action_section}
            flex-100 layout-row layout-align-center-center layout-wrap
          `}
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
      <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
        <div className={`${styles.component_view} flex-65 layout-row layout-align-start-start`}>
          <AdminSearchableHubs
            theme={theme}
            hubs={results}
            adminDispatch={adminDispatch}
            sideScroll={false}
            handleClick={viewTrucking}
            hideFilters
            title=" "
            seeAll={false}
            icon="fa-info-circle"
          />
        </div>
        <div className="flex-20 layout-row layout-wrap layout-align-center-start">
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
                placeholder="Type something..."
                onChange={e => this.handleSearchQuery(e)}
              />
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div
                className={`${styles.action_header} flex-100 layout-row layout-align-start-center`}
                onClick={() => this.toggleExpander('hubType')}
              >
                <div className="flex-90 layout-align-start-center layout-row">
                  <i className="flex-none fa fa-ship" />
                  <p className="flex-none">Hub Type</p>
                </div>
                <div className={`${styles.expander_icon} flex-10 layout-align-center-center`}>
                  {expander.hubType ? (
                    <i className="flex-none fa fa-chevron-up" />
                  ) : (
                    <i className="flex-none fa fa-chevron-down" />
                  )}
                </div>
              </div>
              <div
                className={`${
                  expander.hubType ? styles.open_filter : styles.closed_filter
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
                <div className={`${styles.expander_icon} flex-10 layout-align-center-center`}>
                  {expander.status ? (
                    <i className="flex-none fa fa-chevron-up" />
                  ) : (
                    <i className="flex-none fa fa-chevron-down" />
                  )}
                </div>
              </div>
              <div
                className={`${
                  expander.status ? styles.open_filter : styles.closed_filter
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
                <div className={`${styles.expander_icon} flex-10 layout-align-center-center`}>
                  {expander.countries ? (
                    <i className="flex-none fa fa-chevron-up" />
                  ) : (
                    <i className="flex-none fa fa-chevron-down" />
                  )}
                </div>
              </div>
              <div
                className={`${
                  expander.countries ? styles.open_filter : styles.closed_filter
                } flex-100 layout-row layout-wrap layout-align-center-start`}
              >
                {countryFilters}
              </div>
            </div>
          </div>
        </div>
      </div>
      // //////////////
      // <div className="flex-100 layout-row layout-wrap layout-align-start-start">
      //   <AdminSearchableHubs
      //     theme={theme}
      //     hubs={hubs}
      //     adminDispatch={adminDispatch}
      //     sideScroll={false}
      //     handleClick={viewTrucking}
      //   />
      // </div>
    )
  }
}
AdminTruckingIndex.propTypes = {
  theme: PropTypes.theme,
  viewTrucking: PropTypes.func.isRequired,
  loading: PropTypes.bool,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  adminDispatch: PropTypes.shape({
    getTrucking: PropTypes.func
  }).isRequired,
  truckingNexuses: PropTypes.arrayOf(PropTypes.shape({
    _id: PropTypes.number
  }))
}

AdminTruckingIndex.defaultProps = {
  theme: null,
  loading: false,
  truckingNexuses: [],
  hubs: []
}

export default AdminTruckingIndex
