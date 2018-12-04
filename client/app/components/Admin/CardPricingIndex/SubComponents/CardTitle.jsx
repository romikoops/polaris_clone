import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from '../Card.scss'
import PropTypes from '../../../../prop-types'
import { gradientCSSGenerator } from '../../../../helpers'

function CardTitle (props) {
  const {
    titles, faIcon, theme, t
  } = props

  const colorTheme =
    theme && theme.colors
      ? gradientCSSGenerator(theme.colors.primary, theme.colors.secondary)
      : 'black'

  const setCardBackground = { background: colorTheme }
  const setIconColor = { color: colorTheme }

  return (
    <div
      className={`${styles.card_title_pricing} flex-90 layout-row layout-align-center-center`}
      style={setCardBackground}
    >
      <div className={`${styles.card_over} flex-none`}>
        <div className={styles.center_items}>
          <i className={`fa fa-${faIcon}`} style={setIconColor} />
          <div>
            <h5>{titles}</h5>
            <p>{t('account:routes')}</p>
          </div>
        </div>
      </div>
    </div>
  )
}

CardTitle.propTypes = {
  titles: PropTypes.string.isRequired,
  faIcon: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme.isRequired
}
CardTitle.defaultProps = {}
export default withNamespaces('account')(CardTitle)
