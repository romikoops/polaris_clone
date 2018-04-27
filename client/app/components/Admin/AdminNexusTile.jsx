import React, { Component } from 'react'
import PropTypes from 'prop-types'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'node-uuid'
import styles from './Hubs/AdminHubTile.scss'

export class AdminNexusTile extends Component {
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
    const { nexus, handleClick } = this.props
    if (handleClick) {
      handleClick(nexus)
    }
  }
  render () {
    const {
      theme,
      nexus,
      tooltip,
      showTooltip
    } = this.props
    if (!nexus) {
      return ''
    }
    const bg1 =
      nexus && nexus.photo
        ? { backgroundImage: `url(${nexus.photo})` }
        : {
          backgroundImage:
              'url("https://assets.itsmycargo.com/assets/default_images/aerial_port_sm.jpg")'
        }
    const gradientStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${theme.colors.secondary})`
          : 'black'
    }
    const tooltipId = v4()

    return (
      <div
        className={`something flex-none ${styles.hub_card} layout-row pointy`}
        style={bg1}
        onClick={this.clickEv}
        data-for={tooltipId}
        data-tip={tooltip}
      >
        <div className={styles.fade} />
        <div className={`${styles.content} layout-row`}>
          <div className="flex-15 layout-column layout-align-start-center">
            <i
              className="flex-none fa fa-map-marker"
              style={gradientStyle}
            />
          </div>
          <div className="flex-85 layout-row layout-wrap layout-align-start-start">
            <h4 className="flex-100"> {nexus.name} </h4>
          </div>
        </div>
        {
          showTooltip
            ? <ReactTooltip className={`${styles.tooltip}`} id={tooltipId} effect="solid" />
            : ''
        }
      </div>
    )
  }
}
AdminNexusTile.propTypes = {
  theme: PropTypes.theme,
  nexus: PropTypes.location,
  navFn: PropTypes.func.isRequired,
  handleClick: PropTypes.func.isRequired,
  target: PropTypes.string.isRequired,
  tooltip: PropTypes.string,
  showTooltip: PropTypes.bool
}

AdminNexusTile.defaultProps = {
  theme: null,
  nexus: null,
  tooltip: '',
  showTooltip: false
}

export default AdminNexusTile
