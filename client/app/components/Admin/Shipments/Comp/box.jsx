import React, { Component } from 'react'
// import { v4 } from 'uuid'
import PropTypes from '../../../../prop-types'
import styles from '../../Admin.scss'
import { ShipmentOverviewCard } from '../../../ShipmentCard/ShipmentOverviewCard'

export class AdminShipmentsBox extends Component {
  constructor (props) {
    super(props)

    this.handleClick = this.handleClick.bind(this)
  }

  componentDidUpdate (prevProps) {
    // if (prevProps.shipments !== this.props.shipments) {
    //   this.handleSearchChange({ target: { value: '' } })
    // }
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

  render () {
    const {
      theme,
      userView,
      page,
      dispatches,
      nextPage,
      prevPage,
      handleSearchChange,
      numPages,
      shipments
    } = this.props

    return (
      <div
        className={`layout-row flex-100
         layout-wrap layout-align-start-center ${styles.searchable}`}
      >
        <div
          className={`flex-100 layout-row layout-align-end-center ${
            styles.searchable_header
          }`}
        >
          <div
            className={`${styles.input_box} flex-40 layout-row layout-align-end-center`}
          >
            <input
              type="text"
              name="search"
              placeholder="Search Shipments"
              onChange={handleSearchChange}
            />
          </div>
        </div>
        <ShipmentOverviewCard
          dispatches={dispatches}
          noTitle
          shipments={shipments}
          admin={!userView}
          theme={theme}
        />
        <div className="flex-95 layout-row layout-align-center-center margin_bottom">
          <div
            className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${page === 1 ? styles.disabled : ''}
                    `}
            onClick={page > 1 ? prevPage : null}
          >
            {/* style={page === 1 ? { display: 'none' } : {}} */}
            <i className="fa fa-chevron-left" />
            <p>&nbsp;&nbsp;&nbsp;&nbsp;Back</p>
          </div>
          {}
          <p>{page}</p>
          <div
            className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${page < numPages ? '' : styles.disabled}
                    `}
            onClick={page < numPages ? nextPage : null}
          >
            <p>Next&nbsp;&nbsp;&nbsp;&nbsp;</p>
            <i className="fa fa-chevron-right" />
          </div>
        </div>

      </div>

    )
  }
}
AdminShipmentsBox.propTypes = {
  shipments: PropTypes.arrayOf(PropTypes.shipment).isRequired,
  handleClick: PropTypes.func,
  dispatches: PropTypes.shape({
    getClient: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired,
  seeAll: PropTypes.func,
  theme: PropTypes.theme,
  userView: PropTypes.bool,
  page: PropTypes.number,
  nextPage: PropTypes.func,
  prevPage: PropTypes.func,
  handleSearchChange: PropTypes.func,
  numPages: PropTypes.number
}

AdminShipmentsBox.defaultProps = {
  handleClick: null,
  seeAll: null,
  theme: null,
  userView: false,
  page: 1,
  nextPage: null,
  prevPage: null,
  handleSearchChange: null,
  numPages: 1
}

export default AdminShipmentsBox
