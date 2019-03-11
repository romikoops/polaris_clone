import React from 'react'
import ReactGoogleMapLoader from 'react-google-maps-loader'
import PropTypes from 'prop-types'
import { API_KEY } from '../constants'

export default function GmapsWrapper (props) {
  const apiKey = API_KEY
  const params = {
    key: apiKey, // Define your api key here
    libraries: 'places', // To request multiple libraries, separate them with a comma
    language: 'en'
  }
  const ParamComponent = props.component

  return (
    <ReactGoogleMapLoader
      params={params}
      render={googleMaps => googleMaps && <ParamComponent gMaps={googleMaps} {...props} />}
    />
  )
}

GmapsWrapper.propTypes = {
  component: PropTypes.node.isRequired
}
