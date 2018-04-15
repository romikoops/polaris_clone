import React, { Component } from 'react'
import styles from './Card.scss'
import {
  CardTitle,
  CardRoutePricing,
  PricingButton,
} from './SubComponents'
import { RoundButton } from '../../RoundButton/RoundButton'

// how do i store components in index?

export default class CardPricingIndex extends Component {
  constructor (props) {
    super(props)
    this.iconClasses = {
      ocean: 'anchor',
      air: 'paper-plane',
      rail: 'gratipay'
    }
    this.toggleCreator = this.toggleCreator.bind(this)
  }
    toggleCreator () {
    this.setState({ newPricing: !this.state.newPricing })

  }
  render () {
    const { theme, hubs, pricingData, clients, adminDispatch, scope } = this.props
    if (!scope) return ''
    const modesOfTransport = scope.modes_of_transport
    // ocean: {
    //   container: true,
    //   cargo_item: true
    // },
    const modeOfTransportNames = Object.keys(modesOfTransport)
      .filter(modeOfTransportName => (
        Object.values(modesOfTransport[modeOfTransportName]).some(bool => bool)
      ))
    // const modesOfTransportTitles = modeOfTransportNames
    //   .map(modeOfTransportName => `${modeOfTransportName} freight`)

    return (
      <div>
        <div className="flex-titles">
          {modeOfTransportNames.map(modeOfTransportName => (
            <div className="titles-btn">
              <CardTitle
                titles={`${modeOfTransportName} freight`}
                faIcon={this.iconClasses[modeOfTransportName]}
              />
              <PricingButton />
              <RoundButton
            text="New Pricing"
            theme={theme}
            size="small"
            handleNext={this.toggleCreator}
            iconClass="fa-plus"
            active
          />
          <CardRoutePricing />
            </div>
          ))}
        </div>
      </div>
    )
  }
}
