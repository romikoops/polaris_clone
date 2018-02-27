import React from 'react'
import ReactGoogleMapLoader from 'react-google-maps-loader'
import PropTypes from '../prop-types'
import { API_KEY } from '../constants'

export default function GmapsLoader (props) {
  const params = {
    key: API_KEY, // Define your api key here
    libraries: 'places' // To request multiple libraries, separate them with a comma
  }
  const ParamComponent = props.component
  return (
    <ReactGoogleMapLoader
      params={params}
      render={googleMaps =>
        googleMaps && (
          <ParamComponent
            prevRequest={props.prevRequest}
            allNexuses={props.allNexuses}
            setTargetAddress={props.setTargetAddress}
            theme={props.theme}
            gMaps={googleMaps}
            handleChangeCarriage={props.handleChangeCarriage}
            has_on_carriage={props.has_on_carriage}
            has_pre_carriage={props.has_pre_carriage}
            origin={props.origin}
            destination={props.destination}
            shipment={props.shipment}
            shipmentDispatch={props.shipmentDispatch}
            nextStageAttempt={props.nextStageAttempt}
            handleAddressChange={props.handleAddressChange}
            routeIds={props.routeIds}
            handleSelectLocation={props.handleSelectLocation}
            handleCarriageNexuses={props.handleCarriageNexuses}
          />
        )
      }
    />
  )
}

GmapsLoader.propTypes = {
  theme: PropTypes.theme,
  component: PropTypes.node.isRequired,
  allNexuses: PropTypes.shape({
    origins: PropTypes.array,
    destinations: PropTypes.array
  }).isRequired,
  has_on_carriage: PropTypes.bool,
  has_pre_carriage: PropTypes.bool,
  origin: PropTypes.location.isRequired,
  destination: PropTypes.location.isRequired,
  prevRequest: PropTypes.shape({
    shipment: PropTypes.object
  }),
  shipmentDispatch: PropTypes.shape({
    goTo: PropTypes.func,
    getDashboard: PropTypes.func
  }).isRequired,
  setTargetAddress: PropTypes.func.isRequired,
  handleChangeCarriage: PropTypes.func.isRequired,
  shipment: PropTypes.shipment,
  nextStageAttempt: PropTypes.func.isRequired,
  handleAddressChange: PropTypes.func.isRequired,
  routeIds: PropTypes.arrayOf(PropTypes.object),
  handleSelectLocation: PropTypes.func.isRequired,
  handleCarriageNexuses: PropTypes.func.isRequired
}

GmapsLoader.defaultProps = {
  theme: null,
  routeIds: [],
  prevRequest: null,
  shipment: null,
  has_on_carriage: true,
  has_pre_carriage: true
}
