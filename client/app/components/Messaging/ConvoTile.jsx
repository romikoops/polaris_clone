import React from 'react'
import { withNamespaces } from 'react-i18next'
import styled from 'styled-components'
import styles from './Messaging.scss'
import PropTypes from '../../prop-types'

function ConvoTile ({
  theme, conversation, viewConvo, convoKey, shipment, t
}) {
  const ConvoTileDiv = styled.div`
            
            box-shadow: 0 1px 1px 0 rgba(12,13,14,0.75);
            background: #fff;
    /*        border-width: 2px;
            border-style: solid;
            -webkit-border-image: 
              -webkit-gradient(linear, 0 0, 0 100%, from(${theme.colors.primary}), to(${
  theme.colors.secondary
})) 1 100%;
            -webkit-border-image: 
              -webkit-linear-gradient(${theme.colors.primary}, ${theme.colors.secondary}) 1 100%;
            -moz-border-image:
              -moz-linear-gradient(${theme.colors.primary}, ${theme.colors.secondary}) 1 100%;    
            -o-border-image:
              -o-linear-gradient(${theme.colors.primary}, ${theme.colors.secondary}) 1 100%;
            border-image:
              linear-gradient(to bottom, ${theme.colors.primary}, ${
  theme.colors.secondary
}) 1 100%*/
            border-radius: 10px;
        `
  const iconStyle = {
    background:
      theme && theme.colors
        ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
        : 'black'
  }
  const shipmentStatus = () => {
    const color = { color: '' }
    let icon = ''
    switch (shipment.status) {
      case 'requested':
        icon = 'fa fa-hourglass-half'
        color.color = '#DEBC4C'
        break
      case 'confirmed':
        icon = 'fa fa-check'
        color.color = '#3ACE62'
        break
      case 'rejected':
        icon = 'fa fa-times'
        color.color = '#CE3F3F'
        break
      default:
        icon = 'fa fa-question'
        color.color = '#A19F9F'
        break
    }

    return <i className={icon} style={color} />
  }
  const showStatus = shipmentStatus()
  const ConvoView = (
    <ConvoTileDiv
      className={`flex layout-row layout-align-center-start-space-between pointy layout-wrap ${styles.convo_tile} `}
    >
      <div className="flex-95 layout-row layout-align-start-center">
        <div className="flex-15-layout-row-layout-align-start-center">
          { shipment.convoKey ? <i className={`flex-none clip fa ${shipment.icon}`} style={iconStyle} />
            : <i className="flex-none clip fa fa-truck" style={iconStyle} /> }
        </div>
        <div className="flex-5" />
        <p className="flex-none">{t('bookconf:shipmentReference')}:</p>
        <div className="flex-5" />
        <b>{convoKey}</b>
      </div>
      <div className="flex-95 layout-row layout-align-start-center">
        { shipment.convoKey ? `${shipment.origin} - ${shipment.destination}`
          : t('shipment:rejectedByAdmin') }
      </div>
      <div className="flex-95 layout-row layout-align-start-center">
        {t('common:status').toUpperCase()}:
        <div className="flex-5" />
        <i>
          <b>
            { shipment.convoKey ? shipment.status.toUpperCase()
              : t('shipment:rejected').toUpperCase() }
          </b>
        </i>
        <div className="flex-5" />
        {showStatus}
      </div>
      <p className="flex-none" />
    </ConvoTileDiv>
  )

  return (
    <div
      className={`flex-100 layout-row layout-align-start-start  ${styles.convo_tile_wrapper}`}
      onClick={() => viewConvo(convoKey)}
    >
      { ConvoView }
    </div>
  )
}

ConvoTile.propTypes = {
  theme: PropTypes.theme,
  viewConvo: PropTypes.func.isRequired,
  convoKey: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  conversation: PropTypes.shape({
    messages: PropTypes.array
  }).isRequired,
  shipment: PropTypes.objectOf(PropTypes.any).isRequired
}

ConvoTile.defaultProps = {
  theme: null
}

export default withNamespaces(['bookconf', 'shipment', 'common'])(ConvoTile)
