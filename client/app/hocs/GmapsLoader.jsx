import React from 'react'
import ReactGoogleMapLoader from 'react-google-maps-loader'
import PropTypes from '../prop-types'
import { API_KEY } from '../constants'

export default function GmapsLoader (props) {
  const apiKey = API_KEY
  const params = {
    key: apiKey, // Define your api key here
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
            setCarriage={props.toggleCarriage}
            origin={props.origin}
            destination={props.destination}
            shipment={props.shipment}
            shipmentDispatch={props.shipmentDispatch}
            nextStageAttempt={props.nextStageAttempt}
            handleAddressChange={props.handleAddressChange}
            routeIds={props.routeIds}
            nexusDispatch={props.nexusDispatch}
            availableDestinations={props.availableDestinations}
            handleSelectLocation={props.handleSelectLocation}
          />
        )
      }
    />
  )
}

GmapsLoader.propTypes = {
  theme: PropTypes.theme,
  component: PropTypes.node.isRequired,
  allNexuses: PropTypes.arrayOf(PropTypes.object),
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
  toggleCarriage: PropTypes.func.isRequired,
  shipment: PropTypes.shipment,
  nextStageAttempt: PropTypes.func.isRequired,
  handleAddressChange: PropTypes.func.isRequired,
  routeIds: PropTypes.arrayOf(PropTypes.object),
  nexusDispatch: PropTypes.func.isRequired,
  availableDestinations: PropTypes.arrayOf(PropTypes.object),
  handleSelectLocation: PropTypes.func.isRequired
}

GmapsLoader.defaultProps = {
  theme: null,
  allNexuses: [],
  availableDestinations: [],
  routeIds: [],
  prevRequest: null,
  shipment: null
}
