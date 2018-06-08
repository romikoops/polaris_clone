import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { AdminHubCard as AHubCard } from './AdminHubCard'
import styles from './AdminHubCards.scss'

function listHubs (hubs) {
  return Object.keys(hubs).length > 0 ? Object.keys(hubs).map((hub) => {
    const HubCard = (
      <div className={`flex-22 ${styles.hub}`}>
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
      hubs
    } = this.props

    return (
      <div className="layout-wrap layout-row flex-100 layout-align-space-between-stretch">
        <div className={`layout-padding flex-100 layout-align-start-center ${styles.greyBg}`}>
          <span><b>Hubs</b></span>
        </div>
        {listHubs(hubs)}
      </div>
    )
  }
}

AdminHubCards.propTypes = {
  hubs: PropTypes.objectOf(PropTypes.hub)
}

AdminHubCards.defaultProps = {
  hubs: {}
}

export default AdminHubCards
