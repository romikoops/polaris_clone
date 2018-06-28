import React, { Component } from 'react'
// import { v4 } from 'uuid'
import Fuse from 'fuse.js'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
// import { AdminShipmentRow } from '../'
// import { UserShipmentRow } from '../../UserAccount'
import { Tooltip } from '../../Tooltip/Tooltip'
import { TextHeading } from '../../TextHeading/TextHeading'
import { ShipmentOverviewCard } from '../../ShipmentCardNew/ShipmentOverviewCard'

export class AdminSearchableShipments extends Component {
  constructor (props) {
    super(props)
    this.state = {
      shipments: props.shipments
    }
    this.handleSearchChange = this.handleSearchChange.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.seeAll = this.seeAll.bind(this)
    this.limitArray = this.limitArray.bind(this)
  }

  componentDidUpdate (prevProps) {
    if (prevProps.shipments !== this.props.shipments) {
      this.handleSearchChange({ target: { value: '' } })
    }
  }
  seeAll () {
    const { seeAll, dispatches } = this.props
    if (seeAll) {
      seeAll()
    } else {
      dispatches.getShipments(true)
    }
  }

  handleClick (shipment) {
    const { handleClick, dispatches } = this.props
    if (handleClick) {
      handleClick(shipment)
    } else {
      dispatches.getShipment(shipment.id, true)
    }
  }
  handleSearchChange (event) {
    if (event.target.value === '') {
      this.setState({
        shipments: this.props.shipments
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
        includeScore: true,
        keys
      }
      const fuse = new Fuse(this.props.shipments, options)
      const results = fuse.search(event.target.value)
      const exactResult = results.find(result => result.score === 0)

      return exactResult ? [exactResult.item] : results.map(result => result.item)
    }

    const filteredShipments = search([
      'imc_reference',
      'companyName',
      'originHub',
      'destinationHub',
      'clientName'
    ])

    this.setState({
      shipments: filteredShipments
    })
  }
  limitArray (shipments) {
    const { limit } = this.props

    return limit ? shipments.slice(0, limit) : shipments
  }

  render () {
    const {
      theme,
      title,
      userView,
      seeAll,
      tooltip,
      dispatches
    } = this.props
    const { shipments } = this.state
    let shipmentsArr
    if (shipments.length) {
      shipmentsArr = this.limitArray(shipments)
    } else if (this.props.shipments) {
      shipmentsArr = this.limitArray(this.props.shipments)
    }
    return (
      <div
        className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.searchable}`}
      >
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${
            styles.searchable_header
          }`}
        >
          <div className="flex-60 layout-row layout-align-start-center">
            <div className="flex-100 layout-row layout-align-space-between-center">
              {/* <div className="flex-none layout-row layout-align-start-center">
                <div className="flex-none">
                  <TextHeading theme={theme} size={2} color="white" text={title || 'Shipments'} />
                </div>
                <Tooltip theme={theme} icon="fa-info-circle" toolText={tooltip} />
              </div> */}
            </div>
          </div>
          <div className={`${styles.input_box} flex-40 layout-row layout-align-end-center`}>
            <input
              type="text"
              name="search"
              placeholder="Search Shipments"
              onChange={this.handleSearchChange}
            />
          </div>
        </div>
        <ShipmentOverviewCard
          dispatches={dispatches}
          noTitle
          shipments={shipmentsArr}
          admin={!userView}
          theme={theme}
        />
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
AdminSearchableShipments.propTypes = {
  shipments: PropTypes.arrayOf(PropTypes.shipment).isRequired,
  handleClick: PropTypes.func,
  dispatches: PropTypes.shape({
    getClient: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired,
  seeAll: PropTypes.func,
  title: PropTypes.string,
  theme: PropTypes.theme,
  limit: PropTypes.number,
  userView: PropTypes.bool,
  tooltip: PropTypes.string
}

AdminSearchableShipments.defaultProps = {
  handleClick: null,
  seeAll: null,
  theme: null,
  limit: 0,
  tooltip: '',
  userView: false,
  title: 'shipment'
}

export default AdminSearchableShipments
