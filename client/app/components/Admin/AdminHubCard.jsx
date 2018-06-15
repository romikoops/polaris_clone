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

    const bg =
      hub.data && hub.data.photo
        ? { backgroundImage: `url(${hub.data.photo})` }
        : {
          backgroundImage:
            'url("https://assets.itsmycargo.com/assets/default_images/crane_sm.jpg")'
        }

    return (
      <div
        className={
          `layout-row layout-align-start-stretch
          ${styles.container} ${styles.relative}`
        }
      >
        <div className={`layout-column flex-100 ${styles.city}`}>
          <div className="layout-column layout-padding flex-50 layout-align-center-start">
            <p>{hub ? hub.location.city : ''}<br />
              {hub ? stationType(hub.data.hub_type) : ''}
            </p>
          </div>
          <div className="layout-column flex-50">
            <span className="flex-100" style={bg} />
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
