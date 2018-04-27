import React, { Component } from 'react'
import styles from './Card.scss'
import { v4 } from 'node-uuid'
import {
  CardTitle,
  CardRoutesPricing,
  PricingButton,
} from './SubComponents'
import { RoundButton } from '../../RoundButton/RoundButton'


export default class CardPricingIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      itineraries: props.itineraries
    }
    this.handleClick = this.handleClick.bind(this)
    this.iconClasses = {
      ocean: 'anchor',
      air: 'paper-plane',
      rail: 'truck'
    }
  }

  handleClick (id) {
    const { adminDispatch } = this.props
    // if (handleClick) {
    //   handleClick(itinerary)
    // } else {
      adminDispatch.getItineraryPricings(id, true)
    // }
  }
  generateViewType (mot, limit) {
       return (
        <div className="layout-row flex-100 layout-align-start-center ">
          <div className="layout-row flex-none layout-align-start-center layout-wrap">
            {this.generateCardPricings(mot, limit)}
          </div>
        </div>
      )
    }
    generateCardPricings(mot, limit) {
      const { itineraries } = this.state
      const { hubs, theme } = this.props
      console.log(mot, limit)
    let itinerariesArr = []
    const viewLimit = limit || 3
    if (itineraries && itineraries.length > 0) {
      itinerariesArr = itineraries.filter(itinerary => itinerary.mode_of_transport === mot).map((rt, i) => {
        if (i <= viewLimit) {
          return (
            <CardRoutesPricing
              key={v4()}
              hubs={hubs}
              itinerary={rt}
              theme={theme}
              handleClick={this.handleClick}
            />
          )
        }
        return ''
      })
    } else if (this.props.itineraries && this.props.itineraries.length > 0) {
      itinerariesArr = itineraries.filter(itinerary => itinerary.mode_of_transport === mot).map((rt, i) => {
        if (i <= viewLimit) {
          return (
            <CardRoutesPricing
              key={v4()}
              hubs={hubs}
              itinerary={rt}
              theme={theme}
              handleClick={this.handleClick}
            />
          )
        }
        return ''
      })
    }
    return itinerariesArr
    }


  render () {
    const { theme, hubs, limit, clients, adminDispatch, scope, toggleCreator } = this.props
    if (!scope) return ''
    const modesOfTransport = scope.modes_of_transport
    const modeOfTransportNames = Object.keys(modesOfTransport)
      .filter(modeOfTransportName => (
        Object.values(modesOfTransport[modeOfTransportName]).some(bool => bool)
      ))

    return (
      <div>
        <div className={styles.flex_titles}>
          {modeOfTransportNames.map(modeOfTransportName => (
            <div className={styles.titles_btn}>
              <CardTitle
                titles={`${modeOfTransportName} freight`}
                faIcon={this.iconClasses[modeOfTransportName]}
                theme={theme}
              />
              <PricingButton
                onClick={toggleCreator}
                onDisabledClick={() => console.log('this button is disabled')}
              />
          {this.generateViewType(modeOfTransportName, limit)}
            </div>
          ))}
        </div>
      </div>
    )
  }
}
