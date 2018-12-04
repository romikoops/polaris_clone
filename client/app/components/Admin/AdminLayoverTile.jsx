import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './AdminLayoverTile.scss'
import { moment } from '../../constants'

export class AdminLayoverTile extends Component {
  constructor (props) {
    super(props)
    this.handleLink = this.handleLink.bind(this)
    this.clickEv = this.clickEv.bind(this)
  }
  handleLink () {
    const { target, navFn } = this.props
    console.log(`NAV ${target}`)
    navFn(target)
  }
  clickEv () {
    const { hub, handleClick } = this.props
    if (handleClick) {
      handleClick(hub.data)
    }
  }
  render () {
    const { t, theme, layoverData } = this.props
    if (!layoverData) {
      return ''
    }
    const { layover, hub } = layoverData
    const bg1 = hub && hub.photo ? { backgroundImage: `url(${hub.photo})` } : { backgroundImage: 'url("https://assets.itsmycargo.com/assets/default_images/aerial_port_sm.jpg")' }
    const gradientStyle = {
      background:
                theme && theme.colors
                  ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${
                    theme.colors.secondary
                  })`
                  : 'black'
    }
    const arrival = (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        <div className={`flex-100 layout-row layout-align-start-center ${styles.time_header}`}>
          <p className="flex-none no_m">{t('admin:arrival')}</p>
        </div>
        <div className={`flex-100 layout-row layout-align-end-center ${styles.time_text}`}>
          <p className="flex-none no_m">{moment(layover.eta).format('YYYY-MM-DD HH:mm')}</p>
        </div>
      </div>
    )

    return (
      <div className={`flex-none ${styles.hub_card} layout-row pointy`} style={bg1} onClick={this.clickEv}>
        <div className={styles.fade} />
        <div className={`${styles.content} layout-row layout-wrap`}>
          <div className="flex-100 layout-row layout-align-start-center">
            <div className="flex-15 layout-column layout-align-start-center">
              <i className="flex-none fa fa-map-marker" style={gradientStyle} />
            </div>
            <div className="flex-85 layout-row layout-wrap layout-align-start-start">
              <h4 className="flex-100"> {hub.name} </h4>
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-start-center layout-wrap">
            {layover.eta ? arrival : ''}
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
              <div className={`flex-100 layout-row layout-align-start-center ${styles.time_header}`}>
                <p className="flex-none no_m">{t('admin:departure')}</p>
              </div>
              <div className={`flex-100 layout-row layout-align-end-center ${styles.time_text}`}>
                <p className="flex-none no_m">{moment(layover.etd).format('YYYY-MM-DD HH:mm')}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
AdminLayoverTile.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  hub: PropTypes.objectOf(PropTypes.any).isRequired,
  navFn: PropTypes.func.isRequired,
  handleClick: PropTypes.func.isRequired,
  target: PropTypes.String,
  layoverData: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminLayoverTile.defaultProps = {
  theme: null,
  target: null
}

export default withNamespaces('admin')(AdminLayoverTile)
