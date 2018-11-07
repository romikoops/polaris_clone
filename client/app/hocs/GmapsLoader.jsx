import React from 'react'
import ReactGoogleMapLoader from 'react-google-maps-loader'
import PropTypes from '../prop-types'
import { API_KEY } from '../constants'

export default function GmapsLoader (props) {
  const params = {
    key: API_KEY, // Define your api key here
    libraries: 'places', // To request multiple libraries, separate them with a comma
    language: 'en'
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
            handleCarriageChange={props.handleCarriageChange}
            has_on_carriage={props.has_on_carriage}
            has_pre_carriage={props.has_pre_carriage}
            origin={props.origin}
            destination={props.destination}
            shipmentData={props.shipmentData}
            shipmentDispatch={props.shipmentDispatch}
            nextStageAttempts={props.nextStageAttempts}
            handleAddressChange={props.handleAddressChange}
            routeIds={props.routeIds}
            setNotesIds={(e, t) => props.setNotesIds(e, t)}
            handleSelectLocation={props.handleSelectLocation}
            scope={props.scope}
            {...props}
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
  origin: PropTypes.address.isRequired,
  destination: PropTypes.address.isRequired,
  prevRequest: PropTypes.shape({
    shipment: PropTypes.object
  }),
  setNotesIds: PropTypes.func,
  shipmentDispatch: PropTypes.shape({
    goTo: PropTypes.func,
    getDashboard: PropTypes.func
  }).isRequired,
  setTargetAddress: PropTypes.func.isRequired,
  handleCarriageChange: PropTypes.func.isRequired,
  shipmentData: PropTypes.shipmentData,
  nextStageAttempts: PropTypes.integer,
  handleAddressChange: PropTypes.func.isRequired,
  routeIds: PropTypes.arrayOf(PropTypes.object),
  handleSelectLocation: PropTypes.func.isRequired,
  scope: PropTypes.scope.isRequired
}

GmapsLoader.defaultProps = {
  theme: null,
  routeIds: [],
  prevRequest: null,
  shipmentData: null,
  setNotesIds: null,
  has_on_carriage: true,
  has_pre_carriage: true,
  nextStageAttempts: 0
}
