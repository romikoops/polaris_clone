import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { AdminHubCard as AHubCard } from './AdminHubCard'
import styles from './AdminHubCards.scss'

function listHubs (hubs, adminDispatch) {
  return Object.keys(hubs).length > 0 ? Object.keys(hubs).map((hub) => {
    const HubCard = (
      <div
        className={`flex-25 flex-gt-lg-15 ${styles.hub}`}
        onClick={() => adminDispatch.getHub(hub, true)}
      >
        <AHubCard
          hub={hubs[hub]}
        />
      </div>
    )

    return HubCard
  }) : (<span className={`${styles.hub}`}>No hubs available</span>)
}

export class AdminHubCards extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      hubs,
      adminDispatch
    } = this.props

    return (
      <div className={`layout-wrap layout-row flex-100 layout-align-space-between-stretch ${styles.container}`}>
        <div className={`layout-padding flex-100 layout-align-start-center ${styles.greyBg}`}>
          <span><b>Hubs</b></span>
        </div>
        {listHubs(hubs, adminDispatch)}
      </div>
    )
  }
}

AdminHubCards.propTypes = {
  adminDispatch: PropTypes.objectOf(PropTypes.func),
  hubs: PropTypes.objectOf(PropTypes.hub)
}

AdminHubCards.defaultProps = {
  hubs: {},
  adminDispatch: {}
}

export default AdminHubCards
