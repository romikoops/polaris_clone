import React from 'react'
import Formsy from 'formsy-react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { get } from 'lodash'
import { withNamespaces } from 'react-i18next'
import moment from 'moment'
import getModals from './getModals'
import RouteSection from './RouteSection'
import DayPickerSection from './DayPickerSection'
import CargoSection from './CargoSection'
import GetOffersSection from './GetOffersSection'
import { shipmentActions, bookingProcessActions } from '../../actions'

class ShipmentDetails extends React.PureComponent {
  constructor (props) {
    super(props)
    this.toggleModal = this.toggleModal.bind(this)
    this.getVisibleModal = this.getVisibleModal.bind(this)
    this.getOffers = this.getOffers.bind(this)
    this.handleInvalidGetOffersAttempt = this.handleInvalidGetOffersAttempt.bind(this)

    this.modalsElements = getModals(
      props,
      name => this.toggleModal(name),
      props.t
    )

    if (props.shipment.id && props.shipment.id !== props.shipmentId) {
      const { loadType, direction } = props.shipment
      props.bookingProcessDispatch.resetStore()
      props.bookingProcessDispatch.updateShipment('loadType', loadType)
      props.bookingProcessDispatch.updateShipment('direction', direction)
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
        cargo_items_attributes: shipment.loadType === 'cargo_item' && !shipment.aggregatedCargo ? shipment.cargoUnits : [],
        containers_attributes: shipment.loadType === 'container' ? shipment.cargoUnits : [],
        trucking: shipment.trucking,
        incoterm: {},
        aggregated_cargo_attributes: {
          weight: shipment.aggregatedCargo ? shipment.cargoUnits[0].totalWeight : 0,
          volume: shipment.aggregatedCargo ? shipment.cargoUnits[0].totalVolume : 0
        }
      }
    }
    getOffers(request, true)
  }

  getVisibleModal () {
    const { BookingDetails } = this.props
    const { modals } = BookingDetails
    const [visibleModalKey] = Object.keys(modals).filter(
      key => modals[key]
    )
    if (!visibleModalKey) return ''

    return this.modalsElements[visibleModalKey].jsx
  }

  handleInvalidGetOffersAttempt () {
    console.log('Invalid Attempt', this.props)
  }

  toggleModal (name) {
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateModals(name)
  }

  render () {
    const { t } = this.props

    return (
      <div
        className="layout-row flex-100 layout-wrap no_max SHIP_DETAILS layout-align-start-start"
        style={{ minHeight: '90%' }}
      >
        {this.getVisibleModal()}

        <Formsy
          onValidSubmit={this.getOffers}
          onInvalidSubmit={this.handleInvalidGetOffersAttempt}
          className="flex-100 layout-row layout-wrap"
        >
          <RouteSection />
          <DayPickerSection />
          <CargoSection toggleModal={this.toggleModal} t={t} />
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

export default withNamespaces(['errors', 'cargo', 'common', 'dangerousGoods'])(connect(mapStateToProps, mapDispatchToProps)(ShipmentDetails))
