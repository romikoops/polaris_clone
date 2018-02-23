import React from 'react'
import styled from 'styled-components'
import styles from './Messaging.scss'
import PropTypes from '../../prop-types'

export function ConvoTile ({
  theme, conversation, viewConvo, convoKey, shipment
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
    const status = { color: '' }
    switch (shipment.status) {
      case 'requested': status.color = '#E5E04B'
        break
      case 'confirmed': status.color = '#3ACE62'
        break
      default: status.color = '#CE3F3F'
        break
    }
    return status
  }
  const ConvoView = shipment.convoKey ? (
    <ConvoTileDiv className={`flex layout-row layout-align-center-start pointy layout-wrap ${styles.convo_tile}`}>
      <div className="flex-95 layout-row layout-align-start-center">
        <div className="flex-15-layout-row-layout-align-start-center">
          <i className={`flex-none clip fa ${shipment.icon}`} style={iconStyle} />
        </div>
        <p className="flex-none">Shipment Reference:</p> {convoKey}
      </div>
      <div className="flex-95 layout-row layout-align-start-center">
        {shipment.origin} - {shipment.destination}
      </div>
      <div className="flex-95 layout-row layout-align-start-center">
      status: {shipment.status}<i className="fa fa-circle" style={shipmentStatus()} />
      </div>
      <p className="flex-none" />
    </ConvoTileDiv>
  ) : (
    <ConvoTileDiv className={`flex layout-row layout-align-center-start pointy layout-wrap ${styles.convo_tile}`}>
      <div className="flex-95 layout-row layout-align-start-center">
        <div className="flex-15-layout-row-layout-align-start-center">
          <i className="fa fa-times" style={shipmentStatus()} />
        </div>
        <p className="flex-none">Shipment ID: {convoKey}</p>
      </div>
      <div className="flex-95 layout-row layout-align-start-center">
        Shipment has been rejected by the Admin
      </div>
      <div className="flex-95 layout-row layout-align-start-center">
        status: Rejected
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
  conversation: PropTypes.shape({
    messages: PropTypes.array
  }).isRequired,
  shipment: PropTypes.objectOf(PropTypes.any).isRequired
}

ConvoTile.defaultProps = {
  theme: null
}

export default ConvoTile
