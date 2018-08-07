import React, { Component } from 'react'
import moment from 'moment'
import PropTypes from 'prop-types'
import { GreyBox as GBox } from '../GreyBox/GreyBox'
import styles from './AdminClientCardIndex.scss'
import { gradientTextGenerator } from '../../helpers'

function listClients (clients, theme) {
  const gradientFontStyle =
    theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: '#E0E0E0' }

  return clients.length > 0 ? clients.map((client) => {
    const clientCard = (

      <div className={`layout-row flex-100 layout-align-space-between-stretch ${styles.client_box}`}>
        <div className="layout-column flex-50 layout-align-center-stretch">
          <div className="layout-row flex-50 layout-align-start-center">
            <div className="flex-20 layout-row layout-align-center-center">
              <i className="fa fa-user clip" style={gradientFontStyle} />
            </div>
            <div>
              <h4>{client.first_name} {client.last_name}</h4>
            </div>
          </div>
          <div className="layout-row flex-50 layout-align-start-center">
            <span className="flex-20 layout-row layout-align-center-center">
              <i className="fa fa-building clip" style={gradientFontStyle} />
            </span>
            <span className={`flex-80 layout-row layout-align-start-center ${styles.grey}`}>
              <p>{client.company_name}</p>
            </span>
          </div>
        </div>
        {/* <div className="layout-column flex-50 layout-align-center-stretch">
          <div className="layout-row flex-50 layout-align-start-stretch">
            <div className="flex-20">
              <i className={`fa fa-user ${styles.profileIcon}`} />
            </div>
            <div className="flex-80">{client.first_name} {client.last_name}</div>
          </div>
          <div className="layout-row flex-50 layout-align-start-stretch">
            <span className="flex-20">
              <i className={`fa fa-building ${styles.profileIcon}`} />
            </span>
            <span className={`flex-80 ${styles.grey}`}>{client.company_name}</span>
          </div>
        </div> */}
        <span className={`layout-column layout-align-center-end flex-25 ${styles.smallText}`}>
          <b>Last active</b><br />
          <span className={`${styles.grey}`}>
            {moment().diff(moment(client.updated_at), 'days')} days ago
          </span>
        </span>
      </div>
    )

    return (
      <div className={`${styles.listelement}`}>
        <GBox
          padding
          title=""
          subtitle=""
          component={clientCard}
          noMargin
        />
      </div>
    )
  }) : (<span className={`${styles.listelement}`}>No shipments available</span>)
}

export class AdminClientCardIndex extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      clients, theme
    } = this.props

    return (
      <div className={`layout-column flex-100 layout-align-start-stretch ${styles.listComponent}`}>
        <div className="layout-padding layout-align-start-center greyBg">
          <span><b>Clients</b></span>
        </div>
        <div className={`layout-align-start-stretch ${styles.list} ${styles.scrolling}`}>
          {listClients(clients, theme)}
        </div>
      </div>
    )
  }
}

AdminClientCardIndex.propTypes = {
  clients: PropTypes.arrayOf(PropTypes.client),
  theme: PropTypes.theme
}

AdminClientCardIndex.defaultProps = {
  clients: [],
  theme: null
}

export default AdminClientCardIndex
