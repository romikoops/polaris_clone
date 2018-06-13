import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './AdminHubCard.scss'

function stationType (transportMode) {
  let type

  switch (transportMode) {
    case 'ocean':
      type = 'Port'
      break
    case 'air':
      type = 'Airport'
      break
    case 'train':
      type = 'Station'
      break
    default:
      type = ''
      break
  }

  return type
}

export class AdminHubCard extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      hub
    } = this.props

    return (
      <div
        className={
          `layout-row layout-align-start-stretch
          ${styles.container} ${styles.relative}`
        }
      >
        <div className={`layout-column flex-100 ${styles.city}`}>
          <div className="layout-column layout-padding flex-50 layout-align-center-start">
            <span>{hub ? hub.location.city : ''}<br />
              {hub ? stationType(hub.data.hub_type) : ''}
            </span>
          </div>
          <div className="layout-column flex-50">
            <img className="flex-100" src="/app/assets/images/dashboard/stockholm.png" />
          </div>
        </div>
      </div>
    )
  }
}

AdminHubCard.propTypes = {
  hub: PropTypes.hub
}

AdminHubCard.defaultProps = {
  hub: {}
}

export default AdminHubCard
