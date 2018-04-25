import React, { Component } from 'react'
import PropTypes from 'prop-types'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'node-uuid'
import styles from './AdminHubTile.scss'
import { gradientGenerator } from '../../helpers'

export class AdminHubTile extends Component {
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

    return (
      <div
        className={`something flex-none ${styles.hub_card} layout-row layout-wrap pointy`}
        style={gradientStyle}
        onClick={this.clickEv}
        data-for={tooltipId}
        data-tip={tooltip}
      >
        <div className={`${styles.content} layout-row layout-wrap`}>
          <div className={`${styles.hub_name} flex-100 layout-row layout-wrap layout-align-start-center`}>
            <h1 className="flex-none"> {hubName} </h1>
          </div>
          <div className={`${styles.hub_type} flex-100 layout-row layout-wrap layout-align-end-start`}>
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
  showTooltip: PropTypes.bool
}

AdminHubTile.defaultProps = {
  theme: null,
  hub: null,
  tooltip: '',
  showTooltip: false
}

export default AdminHubTile
