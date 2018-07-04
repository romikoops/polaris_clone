import React, { Component } from 'react'
import PropTypes from 'prop-types'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import styles from './AdminHubTile.scss'
import { gradientGenerator, switchIcon } from '../../../helpers'

export class AdminHubTile extends Component {
  constructor (props) {
    super(props)
    this.handleLink = this.handleLink.bind(this)
    this.handleClick = this.handleClick.bind(this)
  }
  handleLink () {
    const { target, navFn } = this.props
    navFn(target)
  }
  handleClick () {
    const { hub, handleClick } = this.props
    if (handleClick) {
      handleClick(hub.data)
    }
  }
  render () {
    const {
      theme, hub, tooltip, showTooltip
    } = this.props
    if (!hub) {
      return ''
    }

    const bg1 =
      hub && hub.data && hub.data.photo
        ? { backgroundImage: `url(${hub.data.photo})` }
        : {
          backgroundImage:
              'url("https://assets.itsmycargo.com/assets/default_images/aerial_port_sm.jpg")'
        }
    const gradientStyle =
        theme && theme.colors
          ? gradientGenerator(theme.colors.primary, theme.colors.secondary)
          : { background: 'black' }
    let hubType = ''
    switch (hub.data.hub_type) {
      case 'ocean':
        hubType = 'Port'
        break
      case 'air':
        hubType = 'Airport'
        break
      case 'rail':
        hubType = 'Railyard'
        break
      default:
        break
    }
    const str = hub.data.name.replace(hubType, '')
    const hubName = str.substring(0, str.length - 1)
    const tooltipId = v4()
    const icon = (
      <div
        className={styles.hello}
        style={gradientStyle}
      >
        {switchIcon(hub.data.hub_type)}
      </div>
    )

    return (
      <div
        className={`something flex-none ${styles.hub_card} ${styles[hub.data.hub_status]} layout-row layout-wrap pointy`}
        style={gradientStyle}
        onClick={this.handleClick}
        data-for={tooltipId}
        data-tip={tooltip}
      >
        { this.props.showIcon && icon }
        <div className={`${styles.content} layout-row layout-wrap`}>
          <div className={`${styles.hub_name} flex-100 layout-row layout-wrap layout-align-start-center`}>
            <h1 className="flex-none"> {hubName} </h1>
          </div>
          <div className={`${styles.hub_type} flex-100 layout-row layout-wrap layout-align-start-start`}>
            <p className="flex-none">{hubType}</p>
          </div>
        </div>
        <div className={`${styles.image} flex-100 layout-row`} style={bg1} />
        {showTooltip ? (
          <ReactTooltip className={styles.tooltip} id={tooltipId} effect="solid" />
        ) : (
          ''
        )}
      </div>
    )
  }
}
AdminHubTile.propTypes = {
  theme: PropTypes.theme,
  hub: PropTypes.hub,
  navFn: PropTypes.func.isRequired,
  handleClick: PropTypes.func.isRequired,
  target: PropTypes.string.isRequired,
  tooltip: PropTypes.string,
  showTooltip: PropTypes.bool,
  showIcon: PropTypes.bool
}

AdminHubTile.defaultProps = {
  theme: null,
  hub: null,
  tooltip: '',
  showTooltip: false,
  showIcon: false
}

export default AdminHubTile
