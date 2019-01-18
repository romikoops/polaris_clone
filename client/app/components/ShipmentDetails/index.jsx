// import React, { Component } from 'react'
// import { withNamespaces } from 'react-i18next'
// import * as Scroll from 'react-scroll'
// import Toggle from 'react-toggle'
// import { bindActionCreators } from 'redux'
// import { connect } from 'react-redux'
// import { get } from 'lodash'
// import ReactTooltip from 'react-tooltip'
// import { errorActions } from '../../actions'
// import PropTypes from '../../prop-types'
// import GmapsLoader from '../../hocs/GmapsLoader'
// import styles from './ShipmentDetails.scss'
// import defaults from '../../styles/default_classes.scss'
// import { moment } from '../../constants'
// import '../../styles/day-picker-custom.scss'
// import { RoundButton } from '../RoundButton/RoundButton'
// import ShipmentLocationBox from '../ShipmentLocationBox/ShipmentLocationBox'
// import ShipmentContainers from '../ShipmentContainers/ShipmentContainers'
// import ShipmentCargoItems from '../ShipmentCargoItems/ShipmentCargoItems'
// import ShipmentAggregatedCargo from '../ShipmentAggregatedCargo/ShipmentAggregatedCargo'
// import {
//   camelize, isEmpty, chargeableWeight, isQuote
// } from '../../helpers'
// import Checkbox from '../Checkbox/Checkbox'
// import NotesRow from '../Notes/Row'
// import '../../styles/select-css-custom.scss'
// import getModals from './getModals'
// import toggleCSS from './toggleCSS'
// import getOffersBtnIsActive, {
//   noDangerousGoodsCondition,
//   stackableGoodsCondition
// } from './getOffersBtnIsActive'
// import formatCargoItemTypes from './formatCargoItemTypes'
// import addressFieldsAreValid from './addressFieldsAreValid'
// import calcAvailableMotsForRoute,
// { shouldUpdateAvailableMotsForRoute } from './calcAvailableMotsForRoute'
// import getRequests from '../ShipmentLocationBox/getRequests'
// import reuseShipments from '../../helpers/reuseShipment'
// import DayPickerSection from './DayPickerSection'

/* Props

  tenant={tenant}
  user={user}
  shipmentData={shipmentData}
  prevRequest={get(request, ['stage2'], {})}
  req={get(request, ['stage1'], {})}
  getOffers={data => shipmentDispatch.getOffers(data, true)}
  setStage={this.selectShipmentStage}
  messages={error ? error.stage2 : []}
  shipmentDispatch={shipmentDispatch}
  bookingSummaryDispatch={bookingSummaryDispatch}
  reusedShipment={reusedShipment}
  showRegistration={showRegistration}
  hideRegistration={() => this.hideRegistration()}

*/

import React from 'react'
import Formsy from 'formsy-react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import RouteSection from './RouteSection'
import DayPickerSection from './DayPickerSection'
import CargoSection from './CargoSection'
import GetOffersSection from './GetOffersSection'
import { shipmentActions } from '../../actions'

class ShipmentDetails extends React.PureComponent {
  constructor (props) {
    super(props)

    this.getOffers = this.getOffers.bind(this)
  }

  getOffers () {
    const { shipmentDetails, shipmentDispatch } = this.props
    const { getOffers } = shipmentDispatch

    // Old Request
    //
    // {
    //   id: this.state.shipment.id,
    //   origin,
    //   destination,
    //   incoterm,
    //   direction: this.state.shipment.direction,
    //   selected_day: selectedDay || moment().format('DD/MM/YYYY'),
    //   trucking: this.state.shipment.trucking,
    //   cargo_items_attributes: this.state.cargoItems,
    //   containers_attributes: this.state.containers,
    //   aggregated_cargo_attributes: this.state.aggregated && this.state.aggregatedCargo
    // }

    // TODO: Build Request using data from the shipmentDetails store
    const request = {}

    getOffers(request)
  }

  render () {
    return (
      <div
        className="layout-row flex-100 layout-wrap no_max SHIP_DETAILS layout-align-start-start"
        style={{ minHeight: '90%' }}
      >
        <Formsy onValidSubmit={this.getOffers} className="flex-100 layout-row layout-wrap">
          <RouteSection />
          {/* <DayPickerSection /> */}
          <CargoSection />
          <GetOffersSection />
        </Formsy>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { shipmentDetails } = state

  return shipmentDetails
}

function mapDispatchToProps (dispatch) {
  return {
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ShipmentDetails)
