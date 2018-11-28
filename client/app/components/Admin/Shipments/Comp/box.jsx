import React, { Component } from 'react'
// import { v4 } from 'uuid'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../../prop-types'
import styles from '../../Admin.scss'
import { concatArrays, uniqueItems, filters } from '../../../../helpers'
import ShipmentOverviewCard from '../../../ShipmentCard/ShipmentOverviewCard'
import { LoadingSpinner } from '../../../LoadingSpinner/LoadingSpinner'

export class AdminShipmentsBox extends Component {
  static switchShipment (status, t) {
    let shipmentStatus
    switch (status) {
      case 'requested':
        shipmentStatus = <p className="flex-none">{t('shipment:asShipmentsRequested')}</p>
        break
      case 'open':
        shipmentStatus = <p className="flex-none">{t('shipment:asShipmentsOpened')}</p>
        break
      case 'finished':
        shipmentStatus = <p className="flex-none">{t('shipment:asShipmentsFinished')}</p>
        break
      case 'rejected':
        shipmentStatus = <p className="flex-none">{t('shipment:asShipmentsRejected')}</p>
        break
      case 'archived':
        shipmentStatus = <p className="flex-none">{t('shipment:asShipmentsArchived')}</p>
        break
      default:
        shipmentStatus = <p className="flex-none">{t('shipment:asShipmentsRequested')}</p>
        break
    }

    return shipmentStatus
  }

  constructor (props) {
    super(props)
    this.handleClick = this.handleClick.bind(this)
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
      status,
      nexuses,
      dispatches,
      nextPage,
      prevPage,
      handleSearchChange,
      numPages,
      shipments,
      t,
      searchFilters,
      handleInput,
      countries,
      confirmShipmentData,
      searchText
    } = this.props

    // const countriesOriginIds = shipments.map(shipment => shipment.origin_nexus.country_id)
    // const countriesDestinationIds = shipments.map(shipment => shipment.destination_nexus.country_id)
    // const shipmentsCountries = countries.filter(country => (
    //   concatArrays(countriesOriginIds, countriesDestinationIds).includes(country.id)))

    if (this.props.getShipmentsRequest) {
      return (
        <LoadingSpinner size="small" />
      )
    }

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
              value={searchText}
              placeholder="Search Shipments"
              onChange={handleSearchChange}
            />
          </div>
        </div>

        {shipments.length === 0 ? (
          <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center margin_bottom">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_subheader
              }`}
            >
              <p className={` ${styles.sec_subheader_text} flex-none`}>{t('shipment:noShipments')}</p>
            </div>
            {AdminShipmentsBox.switchShipment(status, t)}
          </div>
        ) : (
          <ShipmentOverviewCard
            dispatches={dispatches}
            noTitle
            confirmShipmentData={confirmShipmentData}
            shipments={shipments}
            admin={!userView}
            theme={theme}
          />
        )}
        <div className="flex-95 layout-row layout-align-center-center margin_bottom">
          <div
            className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${parseInt(page, 10) === 1 ? styles.disabled : ''}
                    `}
            onClick={parseInt(page, 10) > 1 ? prevPage : null}
          >
            <i className="fa fa-chevron-left" />
            <p>&nbsp;&nbsp;&nbsp;&nbsp;Back</p>
          </div>
          {}
          <p>{page}</p>
          <div
            className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${parseInt(page, 10) < numPages ? '' : styles.disabled}
                    `}
            onClick={parseInt(page, 10) < numPages ? nextPage : null}
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
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  userView: PropTypes.bool,
  confirmShipmentData: PropTypes.objectOf(PropTypes.any),
  page: PropTypes.number,
  nextPage: PropTypes.func,
  prevPage: PropTypes.func,
  handleSearchChange: PropTypes.func,
  numPages: PropTypes.number,
  searchText: PropTypes.string
}

AdminShipmentsBox.defaultProps = {
  handleClick: null,
  seeAll: null,
  theme: null,
  confirmShipmentData: {},
  userView: false,
  page: 1,
  nextPage: null,
  prevPage: null,
  handleSearchChange: null,
  numPages: 1,
  searchText: ''
}

export default withNamespaces('shipment')(AdminShipmentsBox)
