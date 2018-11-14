import React, { Component } from 'react'
import { withRouter } from 'react-router-dom'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import ConvoTile from '../../components/Messaging/ConvoTile'
import Conversation from '../../components/Messaging/Conversation'
import { messagingActions } from '../../actions'
import styles from './MessageCenter.scss'
import { moment } from '../../constants'

class MessageCenter extends Component {
  static transportationIcon (type) {
    let icon = ''
    switch (type) {
      case 'ocean':
        icon = 'fa-ship'
        break
      case 'air':
        icon = 'fa-plane'
        break
      case 'truck':
        icon = 'fa-truck'
        break
      default:
        break
    }

    return icon
  }
  constructor (props) {
    super(props)
    this.state = {
      selectedConvo: false
    }
    this.viewConvo = this.viewConvo.bind(this)
    this.sendMessage = this.sendMessage.bind(this)
    this.filterHubs = this.filterHubs.bind(this)
    this.filterShipments = this.filterShipments.bind(this)
    this.setSelected = this.setSelected.bind(this)
  }
  componentWillMount () {
    const { messageDispatch } = this.props
    messageDispatch.getShipments()
  }
  componentWillReceiveProps (nextProps) {
    if (!nextProps.shipments && !nextProps.loading) {
      const { messageDispatch, conversations } = this.props
      messageDispatch.getShipments(Object.keys(conversations))
    }
  }
  setSelected (key) {
    this.setState({ key })
  }
  viewConvo (convParam) {
    this.setSelected(convParam)
    const { conversations } = this.props
    const selectedConvo = conversations[convParam]

    selectedConvo.shipmentRef = convParam
    this.setState({ selectedConvo: convParam })
    const { messageDispatch } = this.props
    messageDispatch.markAsRead(convParam)
    messageDispatch.getShipment(convParam)
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
    const hub = hubs ? hubs.map(hbs => (hbs.data.id === parseInt(id, 10) ? hbs.data.name : '')) : []

    return hub.filter(name => name !== '')
  }
  filterShipments (convoKey) {
    const { shipments } = this.props
    console.log(shipments)
    let tmpShipment = []
    let shipment = {}
    if (shipments && convoKey) {
      tmpShipment = shipments[convoKey]
    }

    tmpShipment
      ? (shipment = {
        convoKey,
        transportType: tmpShipment.mode_of_transport,
        icon: MessageCenter.transportationIcon(tmpShipment.mode_of_transport),
        origin: this.filterHubs(tmpShipment.origin_hub_id)[0],
        destination: this.filterHubs(tmpShipment.destination_hub_id)[0],
        eta: moment(tmpShipment.planned_eta).format('YYYY-MM-DD'),
        etd: moment(tmpShipment.planned_etd).format('YYYY-MM-DD'),
        totalPrice: Number.parseFloat(tmpShipment.total_price, 10).toFixed(2),
        status: tmpShipment.status
      })
      : (shipment = {})
    console.log(shipment)

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
    let convoKeys = []
    convoKeys = conversations ? Object.keys(conversations) : []

    const convoArray = convoKeys.map(ms => ({
      conversation: conversations[ms].conversation,
      convoKey: ms,
      shipment: this.filterShipments(ms),
      lastUpdated: conversations[ms].conversation.last_updated
    }))
    const { key } = this.state
    const convos = convoArray
      .sort((a, b) => a.lastUpdated - b.lastUpdated)
      .map((cObj) => {
        const tileStyle = key === cObj.convoKey ? styles.selected : styles.unselected

        return (
          <ConvoTile
            key={v4()}
            className={tileStyle}
            theme={theme}
            conversation={cObj.conversation}
            convoKey={cObj.convoKey}
            viewConvo={this.viewConvo}
            shipment={cObj.shipment}
          />
        )
      })
    const { selectedConvo } = this.state
    const textStyle = {
      color: 'white'
    }
    const messageView = selectedConvo ? (
      <Conversation
        key={v4()}
        conversation={conversations[selectedConvo]}
        theme={theme}
        tenant={tenant}
        clients={clients}
        messageDispatch={messageDispatch}
        sendMessage={this.sendMessage}
        shipment={shipment}
        shipmentRef={selectedConvo}
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
              <p>
                {user.last_name}, {user.first_name}
              </p>
            </h3>
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => this.close()}
            >
              <i className="fa fa-times" style={textStyle} />
            </div>
          </div>
          <div className="flex-90 width_100 layout-row layout-align-start-start">
            <div
              className={`flex-30 layout-row layout-wrap layout-align-center-start scroll ${
                styles.convo_list
              }`}
            >
              {convos}
            </div>
            <div
              className={`flex-70 layout-row layout-wrap layout-align-start ${styles.message_list}`}
            >
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
  conversations: PropTypes.object,
  shipments: PropTypes.arrayOf(PropTypes.object)
}

MessageCenter.defaultProps = {
  theme: null,
  user: null,
  tenant: null,
  shipments: {},
  loading: false,
  clients: null,
  shipment: null,
  conversations: null,
  users: null
}

function mapStateToProps (state) {
  const {
    users, authentication, app, messaging, admin
  } = state
  const { tenant } = app
  const { user, loggedIn } = authentication
  const {
    conversations, unread, shipment, loading, shipments
  } = messaging
  const { clients } = admin

  return {
    user,
    users,
    conversations,
    tenant,
    theme: tenant.theme,
    loggedIn,
    unread,
    shipment,
    clients,
    shipments,
    loading
  }
}
function mapDispatchToProps (dispatch) {
  return {
    messageDispatch: bindActionCreators(messagingActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(MessageCenter))
