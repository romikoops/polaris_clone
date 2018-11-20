import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './AdminHubCard.scss'
import { gradientBorderGenerator } from '../../helpers'
import GradientBorder from '../GradientBorder'

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

export class AdminHubCardContent extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      hub, theme
    } = this.props

    const gradientBorderStyle =
      theme && theme.colors
        ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary)
        : { background: 'black' }

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
        <GradientBorder
          wrapperClassName={`layout-column flex-100 ${styles.city}`}
          gradient={gradientBorderStyle}
          className="layout-column flex-100"
          content={(
            <div className="layout-column flex-100">
              <div className="layout-column layout-padding flex-50 layout-align-center-start">
                <p>{hub ? hub.address.city : ''}<br />
                  {hub ? stationType(hub.data.hub_type) : ''}
                </p>
              </div>
              <div className="layout-column flex-50">
                <span className="flex-100" style={bg} />
              </div>
            </div>
          )}
        />
      </div>
    )
  }
}

AdminHubCardContent.propTypes = {
  hub: PropTypes.hub,
  theme: PropTypes.theme
}

AdminHubCardContent.defaultProps = {
  hub: {},
  theme: null
}

export default AdminHubCardContent
