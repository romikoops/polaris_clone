import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { AdminSearchableHubs } from './AdminSearchables'
import styles from './Admin.scss'
import { Checkbox } from '../Checkbox/Checkbox'
import SideOptionsBox from './SideOptions/SideOptionsBox'
import CollapsingBar from '../CollapsingBar/CollapsingBar'
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
      <div className="flex-100 layout-row layout-align-space-between-start">
        <div className={`${styles.component_view} flex-80 flex-sm-100 flex-xs-100 flex-md-70 layout-row layout-align-start-start`}>
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
        <SideOptionsBox
          header="Filters"
          flexOptions="layout-column flex-20 flex-md-30"
          content={
            <div>
              <div
                className="flex-100 layout-row layout-wrap layout-align-center-start input_box_full"
              >
                <input
                  type="text"
                  className="flex-100"
                  value={searchFilters.query}
                  placeholder="Search"
                  onChange={e => this.handleSearchQuery(e)}
                />
              </div>
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
                  faClass="fa fa-star-half-o"
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
            </div>
          }
        />
      </div>
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
