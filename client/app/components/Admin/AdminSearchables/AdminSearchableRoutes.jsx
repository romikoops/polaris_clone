import React, { Component } from 'react'
import Fuse from 'fuse.js'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import { TextHeading } from '../../TextHeading/TextHeading'
import { Tooltip } from '../../Tooltip/Tooltip'
import { WorldMap as WMap } from '../DashboardMap/WorldMap'
import { AdminRouteList } from '../AdminRouteList'

export class AdminSearchableRoutes extends Component {
  constructor (props) {
    super(props)
    this.state = {
      itineraries: props.itineraries,
      hoverId: false
    }
    this.handleSearchChange = this.handleSearchChange.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.seeAll = this.seeAll.bind(this)
  }
  componentDidUpdate (prevProps) {
    if (prevProps.itineraries !== this.props.itineraries) {
      this.handleSearchChange({ target: { value: '' } })
    }
  }
  seeAll () {
    const { seeAll, adminDispatch } = this.props
    if (seeAll) {
      seeAll()
    } else {
      adminDispatch.goTo('/admin/routes')
    }
  }
  handleRouteHover (id) {
    this.setState((prevState) => {
      const { hoverId } = prevState
      return { hoverId: hoverId === id ? false : id }
    })
  }
  handleClick (itinerary) {
    const { handleClick, adminDispatch } = this.props
    if (handleClick) {
      handleClick(itinerary)
    } else {
      adminDispatch.getItinerary(itinerary.id, true)
    }
  }
  handleSearchChange (event) {
    if (event.target.value === '') {
      this.setState({
        itineraries: this.props.itineraries
      })
      return
    }
    const search = (keys) => {
      const options = {
        shouldSort: true,
        tokenize: true,
        threshold: 0.2,
        location: 0,
        distance: 50,
        maxPatternLength: 32,
        minMatchCharLength: 5,
        keys
      }
      const fuse = new Fuse(this.props.itineraries, options)
      return fuse.search(event.target.value)
    }

    const filteredRoutesOrigin = search(['name'])
    const filteredRoutesDestination = search(['mode_of_transport'])

    let TopRoutes = filteredRoutesDestination.filter(itinerary =>
      filteredRoutesOrigin.includes(itinerary))

    if (TopRoutes.length === 0) {
      TopRoutes = filteredRoutesDestination.concat(filteredRoutesOrigin)
    }
    this.setState({
      itineraries: TopRoutes
    })
  }
  render () {
    const {
      theme,
      seeAll,
      limit,
      showTooltip,
      tooltip,
      icon,
      heading,
      hideFilters,
      tile
    } = this.props
    const { itineraries, hoverId } = this.state

    return (
      <div className={`layout-row flex-100 layout-wrap layout-align-start ${styles.searchable}`}>
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${
            styles.searchable_header
          } ${styles.overlay}`}
        >
          <div className="flex-60 layout-row layout-align-start-center">
            <div className="flex-100 layout-row layout-align-space-between-center">
              <div className="flex-none layout-row layout-align-start-center">
                <div className="flex-none">
                  <TextHeading theme={theme} size={2} text={heading} />
                </div>
                {icon && showTooltip ? (
                  <Tooltip theme={theme} icon={icon} toolText={tooltip} />
                ) : (
                  ''
                )}
              </div>
            </div>
          </div>
          { !hideFilters
            ? <div className="flex-35 layput-row layout-align-start-center input_box_full">
              <input
                type="text"
                name="search"
                placeholder="Search routes"
                onChange={this.handleSearchChange}
              />
            </div> : '' }
        </div>
        <div className={`layout-row flex-100 layout-wrap layout-align-start ${styles.searchable}`}>
          <div className="layout-row flex-100 layout-align-space-between-stretch layout-wrap">

            <div className="layout-padding flex-100">
              <WMap
                itineraries={itineraries}
                hoverId={hoverId}
                height={250}
              />
            </div><div className="layout-padding flex-100">
              <AdminRouteList
                itineraries={itineraries}
                limit={limit}
                tile={tile}
                handleClick={itinerary => this.handleClick(itinerary)}
                hoverFn={e => this.handleRouteHover(e)}
              />
            </div>

          </div>
        </div>
        {seeAll !== false ? (
          <div className="flex-100 layout-row layout-align-end-center">
            <div
              className="flex-none layout-row layout-align-center-center pointy"
              onClick={this.seeAll}
            >
              <p className="flex-none">See all</p>
            </div>
          </div>
        ) : (
          ''
        )}
      </div>
    )
  }
}
AdminSearchableRoutes.propTypes = {
  handleClick: PropTypes.func,
  adminDispatch: PropTypes.shape({
    getClient: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired,
  seeAll: PropTypes.func,
  theme: PropTypes.theme,
  limit: PropTypes.number,
  itineraries: PropTypes.arrayOf(PropTypes.any),
  showTooltip: PropTypes.bool,
  icon: PropTypes.string,
  tooltip: PropTypes.string,
  heading: PropTypes.string,
  hideFilters: PropTypes.bool,
  tile: PropTypes.bool
}

AdminSearchableRoutes.defaultProps = {
  handleClick: null,
  seeAll: null,
  theme: null,
  limit: 3,
  itineraries: [],
  icon: '',
  tooltip: '',
  showTooltip: false,
  heading: 'Routes',
  hideFilters: false,
  tile: false
}

export default AdminSearchableRoutes
