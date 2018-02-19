import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import ReactTooltip from 'react-tooltip'
import Fuse from 'fuse.js'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import { TextHeading } from '../../TextHeading/TextHeading'
import { AdminItineraryRow } from '../'

export class AdminSearchableRoutes extends Component {
  constructor (props) {
    super(props)
    this.state = {
      itineraries: props.itineraries
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
      adminDispatch.goTo('/clients')
    }
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
      console.log(fuse)
      return fuse.search(event.target.value)
    }

    const filteredRoutesOrigin = search('name')
    const filteredRoutesDestination = search('mode_of_transport')

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
      hubs, theme, seeAll, limit, showTooltip, tooltip
    } = this.props
    const { itineraries } = this.state
    let itinerariesArr
    const viewLimit = limit || 15
    if (itineraries) {
      itinerariesArr = itineraries.map((rt, i) => {
        if (i <= viewLimit) {
          return (
            <AdminItineraryRow
              key={v4()}
              hubs={hubs}
              itinerary={rt}
              theme={theme}
              handleClick={this.handleClick}
            />
          )
        }
        return ''
      })
    } else if (this.props.itineraries) {
      itinerariesArr = itineraries.map((rt, i) => {
        if (i <= viewLimit) {
          return (
            <AdminItineraryRow
              key={v4()}
              hubs={hubs}
              itinerary={rt}
              theme={theme}
              handleClick={this.handleClick}
            />
          )
        }
        return ''
      })
    }
    const viewType = this.props.sideScroll ? (
      <div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
        <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
          {itinerariesArr}
        </div>
      </div>
    ) : (
      <div className="layout-row flex-100 layout-align-start-center ">
        <div className="layout-row flex-none layout-align-start-center layout-wrap">
          {itinerariesArr}
        </div>
      </div>
    )
    const tooltipId = v4()
    return (
      <div className={`layout-row flex-100 layout-wrap layout-align-start ${styles.searchable}`}>
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${
            styles.searchable_header
          }`}
        >
          <div className="flex-60 layput-row layout-align-start-center">
            <TextHeading theme={theme} size={1} text="Routes" />
          </div>
          <div className="flex-35 layput-row layout-align-start-center input_box_full">
            <input
              type="text"
              name="search"
              placeholder="Search routes"
              onChange={this.handleSearchChange}
            />
          </div>
        </div>
        <div className={`layout-row flex-100 layout-wrap layout-align-start ${styles.searchable}`} data-for={tooltipId} data-tip={tooltip}>
          {viewType}
          {showTooltip ? <ReactTooltip className={`${styles.tooltip}`} id={tooltipId} /> : ''}
        </div>
        {seeAll !== false ? (
          <div className="flex-100 layout-row layout-align-end-center">
            <div className="flex-none layout-row layout-align-center-center" onClick={this.seeAll}>
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
  sideScroll: PropTypes.bool,
  theme: PropTypes.theme,
  limit: PropTypes.number,
  itineraries: PropTypes.arrayOf(PropTypes.any),
  hubs: PropTypes.arrayOf(PropTypes.hub).isRequired,
  showTooltip: PropTypes.bool,
  tooltip: PropTypes.string
}

AdminSearchableRoutes.defaultProps = {
  handleClick: null,
  seeAll: null,
  sideScroll: false,
  theme: null,
  limit: 3,
  itineraries: [],
  showTooltip: false,
  tooltip: ''

}

export default AdminSearchableRoutes
