import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import moment from 'moment'
import PropTypes from 'prop-types'
import GreyBox from '../GreyBox/GreyBox'
import styles from './AdminClientCardIndex.scss'
import { gradientTextGenerator } from '../../helpers'

function listClients (clients, theme, viewClient, t) {
  const gradientFontStyle =
    theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: '#E0E0E0' }

  return clients.length > 0 ? clients.map((client) => {
    const clientCard = (

      <div
        className={`layout-row flex-100 layout-align-space-between-stretch ${styles.client_box}`}
        onClick={() => viewClient(client.id)}
      >
        <div className="layout-column flex-50 layout-align-center-stretch">
          <div className="layout-row flex-50 layout-align-start-center">
            <div className="flex-20 layout-row layout-align-center-center">
              <i className="fa fa-user clip" style={gradientFontStyle} />
            </div>
            <div>
              <h4>{client.firstName} {client.lastName}</h4>
            </div>
          </div>
          <div className="layout-row flex-50 layout-align-start-center">
            <span className="flex-20 layout-row layout-align-center-center">
              <i className="fa fa-building clip" style={gradientFontStyle} />
            </span>
            <span className={`flex-80 layout-row layout-align-start-center ${styles.grey}`}>
              <p>{client.companyName}</p>
            </span>
          </div>
        </div>
        <span className={`layout-column layout-align-center-end flex-25 ${styles.smallText}`}>
          <b>{t('admin:lastActive')}</b><br />
          <span className={`${styles.grey}`}>
            {t('admin:daysAgo', { days: moment().diff(moment(client.updated_at), 'days') })}
          </span>
        </span>
      </div>
    )

    return (
      <div className={`${styles.listelement}`}>
        <GreyBox
          content={clientCard}
          wrapperClassName="card_margin_bottom"
        />
      </div>
    )
  }) : (<span className={`${styles.listelement}`}>{t('shipment:noShipmentsAvailable')}</span>)
}

export class AdminClientCardIndex extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      t, clients, theme, viewClient
    } = this.props

    return (
      <div className={`layout-column flex-100 layout-align-start-stretch ${styles.listComponent}`}>
        <div className="layout-padding layout-align-start-center greyBg">
          <span><b>{t('admin:clients')}</b></span>
        </div>
        <div className={`layout-align-start-stretch ${styles.list} ${styles.scrolling}`}>
          {listClients(clients, theme, viewClient, t)}
        </div>
      </div>
    )
  }
}

AdminClientCardIndex.propTypes = {
  t: PropTypes.func.isRequired,
  clients: PropTypes.arrayOf(PropTypes.client),
  viewClient: PropTypes.func,
  theme: PropTypes.theme
}

AdminClientCardIndex.defaultProps = {
  clients: [],
  viewClient: null,
  theme: null
}

export default withNamespaces(['admin', 'shipment'])(AdminClientCardIndex)
