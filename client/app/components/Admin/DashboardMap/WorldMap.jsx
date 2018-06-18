import React, { Component } from 'react'
import { geoMercator, geoPath } from 'd3-geo'
import { feature } from 'topojson-client'
// import fetch from 'isomorphic-fetch'
import worldMapData from './worldData'

function projection () {
  return geoMercator()
    .scale(150)
    .translate([1000 / 3, 450 / 1.5])
}

/* eslint no-console: "off" */

export class WorldMap extends Component {
  constructor (props) {
    super(props)
    this.state = {
      worlddata: feature(worldMapData, worldMapData.objects.countries).features,
      cities: []
    }

    this.handleCountryClick = this.handleCountryClick.bind(this)
    this.handleMarkerClick = this.handleMarkerClick.bind(this)
  }
  componentWillMount () {
    // fetch('./world-110m.json')
    //   .then((response) => {
    //     if (response.status !== 200) {
    //       // console.log(`There was a problem: ${response.status}`)
    //       return
    //     }
    //     response.json().then((worlddata) => {
    //       this.setState({
    //         worlddata: feature(worlddata, worlddata.objects.countries).features
    //       })
    //     })
    //   })
  }
  handleCountryClick (countryIndex) {
    console.log('Clicked on country: ', this.state.worlddata[countryIndex])
  }
  handleMarkerClick (markerIndex) {
    console.log('Marker: ', this.state.cities[markerIndex])
  }

  render () {
    const { itineraries, hoverId, height, theme } = this.props
    if (!itineraries) return ''
    /* eslint no-else-return: "off" */
    const originArr = []
    const destinationArr = []
    const routeArr = []
    itineraries.forEach((itinerary) => {
      itinerary.routes.forEach((route) => {
        originArr.push({ hovered: itinerary.id === hoverId, data: route.origin, id: itinerary.id })
        destinationArr.push({
          hovered: itinerary.id === hoverId, data: route.destination, id: itinerary.id
        })
        routeArr.push({ hovered: itinerary.id === hoverId, data: route.line, id: itinerary.id })
      })
    })
    return (
      <div className="flex-100">
        <svg width="100%" height={height || '100%'} viewBox="0 0 900 450">
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
                  key={`country-path-${d.id}-${i}`} // eslint-disable-line
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
          {originArr.map(origin => (
            <g className="markers">
              <circle
                key={`marker-origin-${origin.id}`}
                cx={projection()(origin.data)[0]}
                cy={projection()(origin.data)[1]}
                r={10}
                fill={theme && theme.colors ? theme.colors.secondary : '#0A557D'}
                stroke="#FFFFFF"
                className="marker"
                onClick={() => this.handleMarkerClick(origin.id)}
              />
            </g>
          ))
          }{destinationArr.map(destination => (
            <g className="markers">
              <circle
                key={`marker-${destination.id}`}
                cx={projection()(destination.data)[0]}
                cy={projection()(destination.data)[1]}
                r={4}
                fill={theme && theme.colors ? theme.colors.primary : '#FD8836'}
                stroke="#FFFFFF"
                className="marker"
                onClick={() => this.handleMarkerClick(destination.id)}
              />
            </g>
          ))
          }{
            routeArr.map(d => (
              <path
                key={`path-${d.id}`}
                d={geoPath().projection(projection())(d.data)}
                className="route"
                fill="rgba(255, 255, 255, 0)"
                stroke={d.hovered ? 'red' : 'grey'}
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
