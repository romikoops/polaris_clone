import React, { Component } from 'react'
import moment from 'moment'
import PropTypes from 'prop-types'
import { GreyBox as GBox } from '../GreyBox/GreyBox'
import styles from './AdminClientCards.scss'

function listClients (clients) {
  return clients.map((client) => {
    const clientCard = (
      <div className="layout-row flex-100 layout-align-space-between-stretch">
        <div className="layout-column flex-50 layout-align-center-stretch">
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
        </div>
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
        />
      </div>
    )
  })
}

export class AdminClientCards extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      clients
    } = this.props

    return (
      <div className={`layout-column flex-100 layout-align-start-stretch ${styles.listComponent}`}>
        <div className={`layout-padding layout-align-start-center ${styles.greyBg}`}>
          <span><b>Clients</b></span>
        </div>
        <div className={`layout-align-start-stretch ${styles.list}`}>
          {listClients(clients)}
        </div>
      </div>
    )
  }
}

AdminClientCards.propTypes = {
  clients: PropTypes.arrayOf(PropTypes.client)
}

AdminClientCards.defaultProps = {
  clients: {}
}

export default AdminClientCards
