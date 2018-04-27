import React, { Component } from 'react'
import styles from '../Card.scss'
import PropTypes from '../../../../prop-types'
import { gradientCSSGenerator } from '../../../../helpers'

function CardTitle (props) {
  const {
    titles,
    faIcon,
    theme
  } = props

  const colorTheme =
    theme && theme.colors
      ? gradientCSSGenerator(theme.colors.primary, theme.colors.secondary)
      : 'black'

  const setCardBackground = { background: colorTheme }
  const setIconColor = { color: colorTheme }

  return (
    <div
      className={styles.card_title_pricing}
      style={setCardBackground}
    >
      <div className={styles.card_over}>
        <div className={styles.center_items}>
          <i className={`fa fa-${faIcon}`} style={setIconColor}></i>
          <div>
            <h5>{titles}</h5>
            <p>Routes</p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default CardTitle




