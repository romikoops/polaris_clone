import React from 'react'
import ReactGoogleMapLoader from 'react-google-maps-loader'
import PropTypes from '../prop-types'
import { API_KEY } from '../constants'

export default function EditLocationWrapper (props) {
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
            theme={props.theme}
            gMaps={googleMaps}
            handleAddressChange={props.handleAddressChange}
            saveLocation={props.saveLocation}
            {...props}
          />
        )
      }
    />
  )
}

EditLocationWrapper.propTypes = {
  theme: PropTypes.theme,
  saveLocation: PropTypes.func.isRequired,
  handleAddressChange: PropTypes.func,
  component: PropTypes.func.isRequired
}

EditLocationWrapper.defaultProps = {
  theme: null,
  handleAddressChange: null
}
