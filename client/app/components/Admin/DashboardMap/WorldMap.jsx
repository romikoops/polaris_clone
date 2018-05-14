import React, { Component } from "react"
import { geoMercator, geoPath } from "d3-geo"
import { feature } from "topojson-client"

class WorldMap extends Component {
  constructor(props) {
    super(props)
    this.state = {
      worlddata: [],
    }

    this.handleCountryClick = this.handleCountryClick.bind(this)
    this.handleMarkerClick = this.handleMarkerClick.bind(this)
  }
  projection() {
    return geoMercator()
      .scale(100)
      .translate([ 1000 / 2, 450 / 2 ])
  }
  handleCountryClick(countryIndex) {
    console.log("Clicked on country: ", this.state.worlddata[countryIndex])
  }
  handleMarkerClick(markerIndex) {
    console.log("Marker: ", this.state.cities[markerIndex])
  }
  componentDidMount() {
    fetch("https://unpkg.com/world-atlas@1.1.4/world/110m.json")
      .then(response => {
        if (response.status !== 200) {
          console.log(`There was a problem: ${response.status}`)
          return
        }
        response.json().then(worlddata => {
          this.setState({
            worlddata: feature(worlddata, worlddata.objects.countries).features,
          })
        })
      })
  }

  render() {
    const { itineraries } = this.props
    const originArr = itineraries.map(itinerary => {
      if (itinerary.first_stop === undefined) {
        return ''
      } else {
        const lat = itinerary.first_stop.hub.location.latitude
        const lng = itinerary.first_stop.hub.location.longitude
        const coordArr = [ lat, lng ]
        return coordArr
      }
    })
    const destinationArr = itineraries.map(itinerary => {
      if (itinerary.last_stop === undefined) {
        return ''
      } else {
        const lat = itinerary.last_stop.hub.location.latitude
        const lng = itinerary.last_stop.hub.location.longitude
        const coordArr = [ lat, lng ]
        return coordArr
      }
    })

    return (
      <div>
      <p>{}</p>
      <p>{}</p>
      <svg width={ 800 } height={ 450 } viewBox="0 0 800 450">
        <g className="countries">
          {
            this.state.worlddata.map((d,i) => (
              <path
                key={ `path-${ i }` }
                d={ geoPath().projection(this.projection())(d) }
                className="country"
                fill="#DEDEDE"
                stroke="#FFFFFF"
                strokeWidth={ 0.5 }
                onClick={ () => this.handleCountryClick(i) }
              />
            ))
          }
        </g>
        {originArr.map((coordinates, i) => (
          <g className="markers">
              <circle
                key={ `marker-${i}` }
                cx={ this.projection()(coordinates)[0] }
                cy={ this.projection()(coordinates)[1] }
                r={ 4 }
                fill="#74AE93"
                stroke="#FFFFFF"
                className="marker"
                onClick={ () => this.handleMarkerClick(i) }
              />
          </g>
          ))
        }{destinationArr.map((coordinates, i) => (
          <g className="markers">
              <circle
                key={ `marker-${i}` }
                cx={ this.projection()(coordinates)[0] }
                cy={ this.projection()(coordinates)[1] }
                r={ 4 }
                fill="#008ACA"
                stroke="#FFFFFF"
                className="marker"
                onClick={ () => this.handleMarkerClick(i) }
              />
          </g>
          ))
        }
      </svg>
      </div>
    )
  }
}

export default WorldMap
