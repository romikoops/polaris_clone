import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { gradientTextGenerator } from '../../helpers'

export class AdminRouteTile extends Component {
  static dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`
  }

  constructor (props) {
    super(props)
    this.handleLink = this.handleLink.bind(this)
    this.clickEv = this.clickEv.bind(this)
  }
  handleLink () {
    const { target, navFn } = this.props
    navFn(target)
  }
  clickEv () {
    const { handleClick, itinerary } = this.props
    if (handleClick) {
      handleClick(itinerary)
    }
  }

  render () {
    const { theme, hubs, itinerary } = this.props
    if (!itinerary || !hubs) {
      return ''
    }
    let startHub
    let endHub
    hubs.forEach((hub) => {
      if (hub.location.id === itinerary.origin_nexus_id) {
        startHub = hub
      }
      if (hub.location.id === itinerary.destination_nexus_id) {
        endHub = hub
      }
    })
    const bg1 =
      startHub && startHub.location && startHub.location.photo
        ? { backgroundImage: `url(${startHub.location.photo})` }
        : {
          backgroundImage:
              'url("https://assets.itsmycargo.com/assets/default_images/crane_sm.jpg")'
        }
    const bg2 =
      endHub && endHub.location && endHub.location.photo
        ? { backgroundImage: `url(${endHub.location.photo})` }
        : {
          backgroundImage:
              'url("https://assets.itsmycargo.com/assets/default_images/destination_sm.jpg")'
        }
    if (!endHub || !startHub) {
      // ;
    }
    const gradientStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const dashedLineStyles = {
      marginTop: '6px',
      height: '100%',
      width: '2px',
      background:
        theme && theme.colors
          ? this.dashedGradient(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }
    return (
      <div
        className={`flex-none ${styles.hub_card} layout-row layout-wrap pointy`}
        onClick={this.clickEv}
      >
        <div className={`flex-none ${styles.route_hub_bg} layout-row`}>
          <div className={`flex-none ${styles.route_hub_top} layout-row`} style={bg1} />
          <div className={`flex-none ${styles.route_hub_bottom} layout-row`} style={bg2} />
        </div>
        <div className={styles.fade} />
        <div className={`${styles.content} layout-row`}>
          <div
            className={`flex-15 layout-column layout-align-space-between-center ${styles.icon_box}`}
          >
            <i className="flex-none fa fa-map-marker" style={gradientStyle} />
            <div className="flex" style={dashedLineStyles} />
            <i className="flex-none fa fa-map-marker" style={gradientStyle} />
          </div>
          <div className="flex-85 layout-column layout-wrap layout-align-start-start">
            <div
              className={`flex-50 layout-row layout-wrap layout-align-start-start ${
                styles.content_top
              }`}
            >
              <h4 className="flex-100"> {itinerary.origin_nexus} </h4>
              {startHub && startHub.location.geocoded_address ? (
                <p className={`${styles.overflow_hidden} flex-100`}>
                  {startHub.location.geocoded_address}
                </p>
              ) : (
                ''
              )}
            </div>
            <div
              className={`flex-50 layout-row layout-wrap layout-align-start-start ${
                styles.content_bottom
              }`}
            >
              <h4 className="flex-100"> {itinerary.destination_nexus} </h4>
              {endHub && endHub.location.geocoded_address ? (
                <p className={`${styles.overflow_hidden} flex-100`}>
                  {endHub.location.geocoded_address}
                </p>
              ) : (
                ''
              )}
            </div>
          </div>
        </div>
      </div>
    )
  }
}
AdminRouteTile.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  navFn: PropTypes.func.isRequired,
  handleClick: PropTypes.func.isRequired,
  target: PropTypes.string.isRequired,
  itinerary: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminRouteTile.defaultProps = {
  theme: null,
  hubs: []
}

export default AdminRouteTile
