import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { filters } from '../../helpers'
import AdminHubsComp from './Hubs/AdminHubsComp' // eslint-disable-line

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
      tmpFilters.countries[hub.address.country] = true
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
      filter2 = filter1.filter(a => countryKeys.includes(a.address.country))
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
        ['data.name', 'data.hub_type', 'address.country'],
        filter3
      )
    } else {
      filter4 = filter3
    }

    return filter4
  }
  render () {
    const {
      viewTrucking
    } = this.props

    return (
      <div className="flex-100 layout-row layout-align-space-between-start">
        <AdminHubsComp handleClick={viewTrucking} />
      </div>
    )
  }
}
AdminTruckingIndex.propTypes = {
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
  loading: false,
  truckingNexuses: [],
  hubs: []
}

export default AdminTruckingIndex
