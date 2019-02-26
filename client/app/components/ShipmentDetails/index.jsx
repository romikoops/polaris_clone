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
import { getTotalShipmentErrors } from './CargoSection/getErrors'

class ShipmentDetails extends React.PureComponent {
  constructor (props) {
    super(props)
    this.state = { totalShipmentErrors: {}, getOffersDisabled: false }

    this.toggleModal = this.toggleModal.bind(this)
    this.getVisibleModal = this.getVisibleModal.bind(this)
    this.getOffers = this.getOffers.bind(this)
    this.handleInvalidGetOffersAttempt = this.handleInvalidGetOffersAttempt.bind(this)
    this.enableGetOffers = this.enableGetOffers.bind(this)
    this.disableGetOffers = this.disableGetOffers.bind(this)

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

  static getDerivedStateFromProps (nextProps, prevState) {
    const { shipment, maxAggregateDimensions } = nextProps
    const {
      loadType, cargoUnits, preCarriage, onCarriage
    } = shipment
    const { availableMots } = nextProps.ShipmentDetails

    if (loadType !== 'cargo_item' || !availableMots) return {}

    const totalShipmentErrors = getTotalShipmentErrors({
      modesOfTransport: availableMots,
      maxDimensions: maxAggregateDimensions,
      cargoItems: cargoUnits,
      hasTrucking: preCarriage || onCarriage
    })

    return { totalShipmentErrors }
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
        aggregated_cargo_attributes: shipment.aggregatedCargo
          ? {
            weight: shipment.cargoUnits[0].totalWeight,
            volume: shipment.cargoUnits[0].totalVolume
          }
          : null
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

  enableGetOffers () {
    this.setState({ getOffersDisabled: false })
  }

  disableGetOffers () {
    this.setState({ getOffersDisabled: true })
  }

  render () {
    const { totalShipmentErrors, getOffersDisabled } = this.state

    return (
      <div
        className="layout-row flex-100 layout-wrap no_max SHIP_DETAILS layout-align-start-start"
        style={{ minHeight: '90%' }}
      >
        {this.getVisibleModal()}

        <Formsy
          onValidSubmit={this.getOffers}
          onInvalidSubmit={this.handleInvalidGetOffersAttempt}
          onValid={this.enableGetOffers}
          onInvalid={this.disableGetOffers}
          className="flex-100 layout-row layout-wrap"
        >
          <RouteSection />
          <DayPickerSection />
          <CargoSection toggleModal={this.toggleModal} totalShipmentErrors={totalShipmentErrors}/>
          <GetOffersSection totalShipmentErrors={totalShipmentErrors} getOffersDisabled={getOffersDisabled} />
        </Formsy>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { bookingProcess, bookingData } = state
  const { response } = bookingData
  const shipmentId = get(response, 'stage1.shipment.id')
  const maxAggregateDimensions = get(response, 'stage1.maxAggregateDimensions')

  return { ...bookingProcess, shipmentId, maxAggregateDimensions }
}

function mapDispatchToProps (dispatch) {
  return {
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch),
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch)
  }
}

export default withNamespaces(['errors', 'cargo', 'common', 'dangerousGoods'])(
  connect(mapStateToProps, mapDispatchToProps)(ShipmentDetails)
)
