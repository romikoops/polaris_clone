import React from 'react'
import { get } from 'lodash'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { bookingProcessActions } from '../../../actions'
import CargoUnits from './CargoUnits'
import CargoUnitToggleMode from './CargoUnits/CargoUnit/ToggleMode'
import AddUnitButton from './AddUnitButton'
import { getTotalShipmentErrors } from './getErrors'

class CargoSection extends React.PureComponent {
  render () {
    const {
      theme, scope, cargoItemTypes, maxDimensions, shipment, ShipmentDetails, toggleModal, totalShipmentErrors
    } = this.props

    return (
      <div className="route_section_form layout-row flex-100 layout-wrap layout-align-center-center">
        <div className="layout-row flex-none layout-wrap layout-align-center-center content_width_booking">
          {shipment.loadType === 'cargo_item' && (
            <CargoUnitToggleMode disabled={!scope.total_dimensions} checked={shipment.aggregatedCargo} onToggleAggregated={this.handleToggleAggregated} />
          )}
          <CargoUnits
            ShipmentDetails={ShipmentDetails}
            cargoItemTypes={cargoItemTypes}
            toggleModal={toggleModal}
            maxDimensions={maxDimensions}
            onChangeCargoUnitCheckbox={this.handleChangeCargoUnitCheckbox}
            onChangeCargoUnitInput={this.handleChangeCargoUnitInput}
            onChangeCargoUnitSelect={this.handleChangeCargoUnitSelect}
            onDeleteUnit={this.handleDeleteUnit}
            onUpdateCargoUnit={this.handleUpdateCargoUnit}
            scope={scope}
            theme={theme}
            totalShipmentErrors={totalShipmentErrors}
            {...shipment}
          />

          <div className="flex-100 layout-row layout-align-start">
            <AddUnitButton theme={theme} onClick={this.handleAddUnit} />
          </div>
        </div>
      </div>
    )
  }
}

export default CargoSection
