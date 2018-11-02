import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './ActiveRoutes.scss'
import PropTypes from '../../prop-types'
import { Carousel } from '../Carousel/Carousel'
import { activeRoutesData } from '../../constants'

const actRoutesData = activeRoutesData

export function ActiveRoutes ({ theme, t }) {
  return (
    <div className={`layout-row flex-100 layout-wrap ${styles.active_routes}`}>
      <div className={`${styles.service_label} layout-row layout-align-center-center flex-100`}>
        <h2 className="flex-none">{t('common:availableDestinations')}</h2>
      </div>
      <Carousel theme={theme} slides={actRoutesData} noSlides={4} />
    </div>
  )
}

ActiveRoutes.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired
}

ActiveRoutes.defaultProps = {
  theme: null
}

export default withNamespaces('common')(ActiveRoutes)
