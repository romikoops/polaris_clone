import React, { Component } from 'react'
import { v4 } from 'uuid'
import Fuse from 'fuse.js'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import { AdminShipmentRow } from '../'
import { UserShipmentRow } from '../../UserAccount'
import { Tooltip } from '../../Tooltip/Tooltip'
import { TextHeading } from '../../TextHeading/TextHeading'
// import { ShipmentOverviewCard } from '../../ShipmentCardNew/ShipmentOverviewCard'

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
    const { seeAll, adminDispatch } = this.props
    if (seeAll) {
      seeAll()
    } else {
      adminDispatch.getShipments(true)
    }
  }

  handleClick (shipment) {
    const { handleClick, adminDispatch } = this.props
    if (handleClick) {
      handleClick(shipment)
    } else {
      adminDispatch.getShipment(shipment.id, true)
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
      hubs, theme, handleShipmentAction, title, userView, seeAll, tooltip, user
    } = this.props
    const { shipments } = this.state
    // console.log(this.props.shipments)
    let shipmentsArr
    if (shipments.length) {
      shipmentsArr = this.limitArray(shipments).map(ship =>
        (userView ? (
          <UserShipmentRow
            key={v4()}
            shipment={ship}
            hubs={hubs}
            theme={theme}
            user={user}
            handleSelect={this.handleClick}
            handleAction={handleShipmentAction}
          />
        ) : (
          <AdminShipmentRow
            key={v4()}
            shipment={ship}
            hubs={hubs}
            theme={theme}
            handleSelect={this.handleClick}
            handleAction={handleShipmentAction}
          />
        )))
    } else if (this.props.shipments) {
      shipmentsArr = this.limitArray(this.props.shipments).map(ship =>
        (userView ? (
          <UserShipmentRow
            key={v4()}
            shipment={ship}
            hubs={hubs}
            theme={theme}
            user={user}
            handleSelect={this.handleClick}
            handleAction={handleShipmentAction}
          />
        ) : (
          <AdminShipmentRow
            key={v4()}
            shipment={ship}
            hubs={hubs}
            theme={theme}
            handleSelect={this.handleClick}
            handleAction={handleShipmentAction}
          />
        )))
    }
    const viewType = this.props.sideScroll ? (
      <div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
        <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
          {shipmentsArr}
        </div>
      </div>
    ) : (
      <div className="layout-row flex-100 layout-align-start-center ">
        <div className="layout-row flex-100 layout-align-start-center layout-wrap">
          {shipmentsArr}
        </div>
      </div>
    )

    return (
      <div
        className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.searchable}`}
      >
        {console.log(handleShipmentAction)}
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${
            styles.searchable_header
          }`}
        >
          <div className="flex-60 layout-row layout-align-start-center">
            <div className="flex-100 layout-row layout-align-space-between-center">
              <div className="flex-none layout-row layout-align-start-center">
                <div className="flex-none">
                  <TextHeading theme={theme} size={2} text={title || 'Shipments'} />
                </div>
                <Tooltip theme={theme} icon="fa-info-circle" toolText={tooltip} />
              </div>
            </div>
          </div>
          <div className={`${styles.input_box} flex-40 layout-row layout-align-start-center`}>
            <input
              type="text"
              name="search"
              placeholder="Search Shipments"
              onChange={this.handleSearchChange}
            />
          </div>
        </div>
        {viewType}
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
  adminDispatch: PropTypes.shape({
    getClient: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired,
  seeAll: PropTypes.func,
  title: PropTypes.string,
  sideScroll: PropTypes.bool,
  theme: PropTypes.theme,
  limit: PropTypes.number,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  userView: PropTypes.bool,
  tooltip: PropTypes.string,
  user: PropTypes.objectOf(PropTypes.any),
  handleShipmentAction: PropTypes.func.isRequired
}

AdminSearchableShipments.defaultProps = {
  handleClick: null,
  seeAll: null,
  sideScroll: false,
  theme: null,
  limit: 0,
  tooltip: '',
  hubs: [],
  user: {},
  userView: false,
  title: 'shipment'
}

export default AdminSearchableShipments
