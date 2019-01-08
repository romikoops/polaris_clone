import React from 'react'
import Formsy from 'formsy-react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { get } from 'lodash'
import moment from 'moment'
import RouteSection from './RouteSection'
import DayPickerSection from './DayPickerSection'
import CargoSection from './CargoSection'
import GetOffersSection from './GetOffersSection'
import { shipmentActions, bookingProcessActions } from '../../actions'

class ShipmentDetails extends React.PureComponent {
  constructor (props) {
    super(props)

    this.getOffers = this.getOffers.bind(this)
    this.handleInvalidGetOffersAttempt = this.handleInvalidGetOffersAttempt.bind(this)

    if (props.shipment.id && props.shipment.id !== props.shipmentId) {
      props.bookingProcessDispatch.resetStore()
    }

    props.bookingProcessDispatch.updateShipment('id', props.shipmentId)
  }

  getOffers () {
    const { shipment, shipmentDispatch } = this.props
    const { getOffers } = shipmentDispatch

    const request = {
      shipment: {
        id: shipment.id,
        origin: shipment.origin,
        destination: shipment.destination,
        direction: shipment.direction,
        selected_day: shipment.selectedDay || moment().format('DD/MM/YYYY'),

        // TODO: Change what the API expects. This logic belongs in the backend.
        cargo_items_attributes: shipment.loadType === 'cargo_item' ? shipment.cargoUnits : [],
        containers_attributes: shipment.loadType === 'container' ? shipment.cargoUnits : [],

        // TODO: implement
        trucking: shipment.trucking,
        incoterm: {},
        aggregated_cargo_attributes: {
          weight: 0,
          volume: 0
        }
      }
    }

    getOffers(request, true)
  }

  handleInvalidGetOffersAttempt () {
    console.log('Invalid Attempt', this.props)
  }

  render () {
    return (
      <div
        className="layout-row flex-100 layout-wrap no_max SHIP_DETAILS layout-align-start-start"
        style={{ minHeight: '100%' }}
      >
        <Formsy
          onValidSubmit={this.getOffers}
          onInvalidSubmit={this.handleInvalidGetOffersAttempt}
          className="flex-100 layout-row layout-wrap"
        >
          <RouteSection />
          <DayPickerSection />
          <CargoSection />
          <GetOffersSection />
        </Formsy>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { bookingProcess, bookingData } = state
  const { response } = bookingData
  const shipmentId = get(response, 'stage1.shipment.id')

  return { ...bookingProcess, shipmentId }
}

function mapDispatchToProps (dispatch) {
  return {
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch),
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ShipmentDetails)
