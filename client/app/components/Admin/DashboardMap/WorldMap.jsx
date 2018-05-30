import React, { Component } from 'react'
import { geoMercator, geoPath } from 'd3-geo'
import { feature } from 'topojson-client'
import fetch from 'isomorphic-fetch'

function projection () {
  return geoMercator()
    .scale(100)
    .translate([1000 / 2, 450 / 2])
}

/* eslint no-console: "off" */

class WorldMap extends Component {
  constructor (props) {
    super(props)
    this.state = {
      worlddata: [],
      cities: []
    }

    this.handleCountryClick = this.handleCountryClick.bind(this)
    this.handleMarkerClick = this.handleMarkerClick.bind(this)
  }
  componentDidMount () {
    fetch('https://unpkg.com/world-atlas@1.1.4/world/110m.json')
      .then((response) => {
        if (response.status !== 200) {
          // console.log(`There was a problem: ${response.status}`)
          return
        }
        response.json().then((worlddata) => {
          this.setState({
            worlddata: feature(worlddata, worlddata.objects.countries).features
          })
        })
      })
  }
  handleCountryClick (countryIndex) {
    console.log('Clicked on country: ', this.state.worlddata[countryIndex])
  }
  handleMarkerClick (markerIndex) {
    console.log('Marker: ', this.state.cities[markerIndex])
  }

  render () {
    const { itineraries } = this.props
    /* eslint no-else-return: "off" */
    const originArr = itineraries.map((itinerary) => {
      if (itinerary.first_stop === undefined) {
        return ''
      } else {
        const lat = itinerary.first_stop.hub.location.latitude
        const lng = itinerary.first_stop.hub.location.longitude
        const coordArr = [lng, lat]
        return coordArr
      }
    })
    const destinationArr = itineraries.map((itinerary) => {
      if (itinerary.last_stop === undefined) {
        return ''
      } else {
        const lat = itinerary.last_stop.hub.location.latitude
        const lng = itinerary.last_stop.hub.location.longitude
        const coordArr = [lng, lat]
        return coordArr
      }
    })
    const routeArr = itineraries.map((itinerary, i) => {
      if (itinerary.first_stop === undefined || itinerary.last_stop === undefined) {
        return ''
      } else {
        const orilat = itinerary.first_stop.hub.location.latitude
        const orilng = itinerary.first_stop.hub.location.longitude

        const destlat = itinerary.last_stop.hub.location.latitude
        const destlng = itinerary.last_stop.hub.location.longitude

        const data = {
          type: 'LineString',
          id: i,
          coordinates: [[orilng, orilat], [destlng, destlat]]
        }

        return data
      }
    })
    /* eslint react/no-array-index-key: "off" */

    return (
      <div>
        <p>{}</p>
        <p>{}</p>
        <svg width={800} height={450} viewBox="0 0 800 450">
          <defs>
            <marker
              id="mid"
              orient="auto"
              markerWidth="5"
              markerHeight="10"
              refX="0.1"
              refY="5"
            >
              <path d="M0,0 V10 L5,5 Z" fill="grey" />
            </marker>
          </defs>
          <g className="countries">
            {
              this.state.worlddata.map((d, i) => (
                <path
                  key={`path-${i}`}
                  d={geoPath().projection(projection())(d)}
                  className="country"
                  fill="#DEDEDE"
                  stroke="#FFFFFF"
                  strokeWidth={0.5}
                  onClick={() => this.handleCountryClick(i)}
                />
              ))
            }
          </g>
          {originArr.map((coordinates, i) => (
            <g className="markers">
              <circle
                key={`marker-ori-${i}`}
                cx={projection()(coordinates)[0]}
                cy={projection()(coordinates)[1]}
                r={10}
                fill="#74AE93"
                stroke="#FFFFFF"
                className="marker"
                onClick={() => this.handleMarkerClick(i)}
              />
            </g>
          ))
          }{destinationArr.map((coordinates, i) => (
            <g className="markers">
              <circle
                key={`marker-${i}`}
                cx={projection()(coordinates)[0]}
                cy={projection()(coordinates)[1]}
                r={4}
                fill="#008ACA"
                stroke="#FFFFFF"
                className="marker"
                onClick={() => this.handleMarkerClick(i)}
              />
            </g>
          ))
          }{
            routeArr.map((d, i) => (
              <path
                key={`path-${i}`}
                d={geoPath().projection(projection())(d)}
                className="route"
                fill="rgba(255, 255, 255, 0)"
                stroke="grey"
                strokeLinecap="round"
                strokeWidth={0.5}
              />
            ))
          }
        </svg>
      </div>
    )
  }
}
/* eslint react/prop-types: "off" */

export default WorldMap
