import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { AdminHubCardContent } from './AdminHubCardContent'
import styles from './AdminHubCards.scss'

function listHubs (hubs, adminDispatch, theme) {
  return Object.keys(hubs).length > 0 ? Object.keys(hubs).map((hubKey) => {
    const HubCard = (
      <div
        className={`flex-25 flex-gt-lg-15 ${styles.hub}`}
        onClick={() => adminDispatch.getHub(hubKey, true)}
      >
        <AdminHubCardContent
          hub={hubs[hubKey]}
          theme={theme}
        />
      </div>
    )

    return HubCard
  }) : (<span className={`${styles.hub}`}>No hubs available</span>)
}

export class AdminHubCard extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      hubs,
      adminDispatch,
      theme
    } = this.props

    return (
      <div className={`layout-wrap layout-row flex-100 layout-align-space-between-stretch ${styles.container}`}>
        <div className="layout-padding flex-100 layout-align-start-center greyBg">
          <span><b>Hubs</b></span>
        </div>
        <div className={`layout-wrap layout-row flex-100 ${styles.scrolling}`}>
          {listHubs(hubs, adminDispatch, theme)}
        </div>
      </div>
    )
  }
}

AdminHubCard.propTypes = {
  adminDispatch: PropTypes.objectOf(PropTypes.func),
  hubs: PropTypes.objectOf(PropTypes.hub),
  theme: PropTypes.theme
}

AdminHubCard.defaultProps = {
  hubs: {},
  adminDispatch: {},
  theme: null
}

export default AdminHubCard
