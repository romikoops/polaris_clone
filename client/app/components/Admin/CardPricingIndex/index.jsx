import React, { Component } from 'react'
import styles from './Card.scss'
import {
  CardTitle,
  CardRoutesPricing,
  PricingButton,
  CardPricing
} from './SubComponents'

// how do i store components in index?

export default class CardPricingIndex extends Component {
  constructor (props) {
    super(props)

  }
  render () {
    const propValues = {
      titles: ["Ocean freight", "Air freight", "Rails freight"],
      faIcon: [ "ship", "", "" ]
    }
    return propValues.titles.map((title, index) => (
          <div>
            <CardTitle
              titles={title}
              faIcon={propValues.faIcon[index]}
            />
            (ツ?)
          </div>
    ))

  }
}
