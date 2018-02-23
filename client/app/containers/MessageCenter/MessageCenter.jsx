import React, { Component } from 'react'
import { withRouter } from 'react-router-dom'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import PropTypes from '../../prop-types'
import { ConvoTile, Conversation } from '../../components/Messaging'
import { messagingActions } from '../../actions'
import styles from './MessageCenter.scss'
import { moment } from '../../constants'

class MessageCenter extends Component {
  static transportationIcon (type) {
    let icon = ''
    switch (type) {
      case 'ocean': icon = 'fa-ship'
        break
      case 'air': icon = 'fa-plane'
        break
      case 'truck': icon = 'fa-truck'
        break
      default: break
    }
    return icon
  }
  constructor (props) {
    super(props)
    this.state = {
      selectedConvo: false
    }
    this.selectConvo = this.selectConvo.bind(this)
    this.sendMessage = this.sendMessage.bind(this)
    this.filterHubs = this.filterHubs.bind(this)
    this.filterShipments = this.filterShipments.bind(this)
  }
  selectConvo (convParam) {
    const { conversations } = this.props
    const selectedConvo = conversations[convParam]
    selectedConvo.shipmentRef = selectedConvo.messages[0].shipmentRef
    this.setState({ selectedConvo: convParam })
    const { messageDispatch } = this.props
    messageDispatch.markAsRead(selectedConvo.shipmentRef)
    messageDispatch.getShipment(selectedConvo.shipmentRef)
    MessageCenter.scrollToBottom()
  }
  sendMessage (msg) {
    const { messageDispatch } = this.props
    messageDispatch.sendUserMessage(msg)
  }
  close () {
    const { messageDispatch } = this.props
    messageDispatch.showMessageCenter()
  }

  filterHubs (id) {
    const { hubs } = this.props.users
    const hub = hubs.map(hbs => (hbs.data.id === parseInt(id, 10) ? hbs.data.name : ''))
    return hub.filter(name => name !== '')
  }
  filterShipments (convoKey) {
    const { shipments } = this.props.users.dashboard
    let tmpShipment = {}
    let shipment = {}
    if (shipments && convoKey) {
      if (shipments.requested.length > 0 && tmpShipment.length !== 0) {
        tmpShipment = shipments.requested.filter(shp => (shp.imc_reference === convoKey))
      }
      if (shipments.open.length > 0 && tmpShipment.length === 0) {
        tmpShipment = shipments.open.filter(shp => (shp.imc_reference === convoKey))
      }
      if (shipments.finished.length > 0 && tmpShipment.length === 0) {
        tmpShipment = shipments.finished.filter(shp => (shp.imc_reference === convoKey))
      }
    }

    tmpShipment.length > 0
      ? shipment = {
        convoKey,
        transportType: tmpShipment[0].schedule_set[0].mode_of_transport,
        icon: MessageCenter.transportationIcon(tmpShipment[0].schedule_set[0].mode_of_transport),
        origin: this.filterHubs(tmpShipment[0].schedule_set[0].hub_route_key.split('-')[0])[0],
        destination: this.filterHubs(tmpShipment[0].schedule_set[0].hub_route_key.split('-')[1])[0],
        eta: moment(tmpShipment.planned_eta).format('YYYY-MM-DD'),
        etd: moment(tmpShipment.planned_et).format('YYYY-MM-DD'),
        totalPrice: Number.parseFloat(tmpShipment[0].total_price, 10).toFixed(2),
        status: tmpShipment[0].status
      }
      : shipment = {}

    return shipment
  }
  render () {
    const {
      theme,
      messageDispatch,
      conversations,
      user,
      shipment,
      tenant,
      clients,
      loading
    } = this.props
    if (!conversations && !loading) {
      return ''
    }
    let convoKeys = {}
    convoKeys = Object.keys(conversations)
    const convos = convoKeys.map(ms => (
      <ConvoTile
        theme={theme}
        conversation={conversations[ms]}
        convoKey={ms}
        viewConvo={this.selectConvo}
        shipment={this.filterShipments(ms)}
      />
    ))
    const { selectedConvo } = this.state
    const textStyle = {
      color: 'white'
    }
    const messageView = selectedConvo ? (
      <Conversation
        conversation={conversations[selectedConvo]}
        theme={theme}
        tenant={tenant}
        clients={clients}
        messageDispatch={messageDispatch}
        sendMessage={this.sendMessage}
        shipment={shipment}
        user={user}
      />
    ) : (
      <div className="flex-50 layout-row width_100 layout-align-center-start">
        <h3 className="flex-none">Please select a conversation</h3>
      </div>
    )
    return (
      <div
        className={`flex-none layout-row layout-wrap layout-align-center-center ${styles.backdrop}`}
      >
        <div className={`flex-none ${styles.fade}`} onClick={() => this.close()} />
        <div
          className={`flex-none layout-column layout-align-start-start ${styles.message_center}`}
        >
          <div className="flex-10 width_100 layout-row layout-align-space-between-center">
            <h3 className="flex-none letter_3" style={textStyle}>
              Message Center:
              <p>{user.last_name}, {user.first_name}</p>
            </h3>
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => this.close()}
            >
              <i className="fa fa-times" style={textStyle} />
            </div>
          </div>
          <div className="flex-90 width_100 layout-row layout-align-start-start">
            <div className={`flex-30 layout-row layout-wrap layout-align-center-start scroll ${styles.convo_list}`}>
              {convos}
            </div>
            <div className={`flex-70 layout-column layout-align-start-start ${styles.message_list}`} >
              {messageView}
            </div>
          </div>
        </div>
      </div>
    )
  }
}

MessageCenter.propTypes = {
  theme: PropTypes.theme,
  messageDispatch: PropTypes.shape({
    markAsRead: PropTypes.func,
    getShipment: PropTypes.func
  }).isRequired,
  user: PropTypes.user,
  // eslint-disable-next-line react/forbid-prop-types
  users: PropTypes.any,
  tenant: PropTypes.tenant,
  loading: PropTypes.bool,
  // eslint-disable-next-line react/forbid-prop-types
  clients: PropTypes.any,
  // eslint-disable-next-line react/forbid-prop-types
  shipment: PropTypes.any,
  // eslint-disable-next-line react/forbid-prop-types
  conversations: PropTypes.object
}

MessageCenter.defaultProps = {
  theme: null,
  user: null,
  tenant: null,
  loading: false,
  clients: null,
  shipment: null,
  conversations: null,
  users: null
}

function mapStateToProps (state) {
  const {
    users, authentication, tenant, messaging, admin
  } = state
  const { user, loggedIn } = authentication
  const {
    conversations, unread, shipment, loading
  } = messaging
  const { clients } = admin
  return {
    user,
    users,
    conversations,
    tenant,
    theme: tenant.data.theme,
    loggedIn,
    unread,
    shipment,
    clients,
    loading
  }
}
function mapDispatchToProps (dispatch) {
  return {
    messageDispatch: bindActionCreators(messagingActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(MessageCenter))
