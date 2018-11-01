import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import Scroll from 'react-scroll'
import styles from './Messaging.scss'
import defStyles from '../../styles/default_classes.scss'
import MessageShipmentData from './MessageShipmentData'
import Message from './Message'
import PropTypes from '../../prop-types'

class Conversation extends Component {
  constructor (props) {
    super(props)
    this.state = {
      message: '',
      title: '',
      showDetails: false
    }
    this.handleReplyChange = this.handleReplyChange.bind(this)
    this.reply = this.reply.bind(this)
    this.toggleDetails = this.toggleDetails.bind(this)
    this.scrollToBottom = this.scrollToBottom.bind(this)
  }
  componentDidMount () {
    const { scroller } = Scroll
    scroller.scrollTo('messagesEnd', {
      duration: 1000,
      delay: 50,
      smooth: true,
      containerId: 'messageList',
      offset: 50
    })
  }

  handleReplyChange (ev) {
    const { name, value } = ev.target
    this.setState({ [name]: value })
  }
  toggleDetails () {
    this.setState({ showDetails: !this.state.showDetails })
    if (!this.state.showDetails) {
      this.scrollToBottom()
    }
  }
  reply (event) {
    event.preventDefault()
    const { message, title } = this.state
    const { sendMessage, shipmentRef } = this.props
    const msg = {
      title,
      message,
      shipmentRef
    }
    this.setState({
      message: '',
      title: ''
    })
    sendMessage(msg)
    this.scrollToBottom()
  }
  scrollToBottom () {
    this.el.scrollIntoView({ behavior: 'smooth' })
  }
  render () {
    const {
      conversation, theme, shipment, user, tenant, clients, t
    } = this.props
    const { message, title, showDetails } = this.state
    const { Element } = Scroll
    const isAdmin = user.role && user.role.name === 'admin'
    const messages = isAdmin
      ? conversation.messages.map((msg) => {
        const client = clients.filter(c => c.id === msg.user_id)[0]

        return (
          <Message
            tenant={tenant}
            user={user}
            message={msg}
            client={client}
            theme={theme}
            key={v4()}
          />
        )
      })
      : conversation.messages.map(msg =>
        (<Message
          tenant={tenant}
          user={user}
          message={msg}
          theme={theme}
          key={v4()}
        />))
    const btnStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${
            theme.colors.primary
          },${
            theme.colors.secondary
          })`
          : 'black'
    }
    const detailView = (<MessageShipmentData
      theme={theme}
      shipmentData={shipment}
      user={user}
      closeInfo={this.toggleDetails}
    />)
    const messageView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start" ref>
        <div
          id="messageList"
          className={`${styles.message_scroll}
          flex-100 layout-row layout-align-start-start layout-wrap `}
        >
          <div className="flex-70 layout-row layout-align-start-start layout-wrap" >
            { messages }
          </div>

          <Element name="messagesEnd" />
        </div>
        <form
          className={`${styles.msg_form} ${defStyles.border_divider} flex-100  layout-row layout-align-start-center`}
          onSubmit={this.reply}
        >
          <div
            className="flex-90 layout-row layout-align-center-space-around height_100 layout-wrap"
          >
            <div className="flex-95 layout-row layout-align-center-center input_box">
              <input
                type="text"
                name="title"
                className={`flex-90 ${styles.text_input}`}
                placeholder={t('account:typeTitle')}
                value={title}
                onChange={this.handleReplyChange}
              />
            </div>
            <div className="flex-95 layout-row layout-align-center-center">
              <textarea
                name="message"
                placeholder={t('account:typeMessage')}
                id=""
                className={`flex-90 ${styles.text_area}`}
                value={message}
                cols="30"
                rows="5"
                onChange={this.handleReplyChange}
              />
            </div>
          </div>
          <div className="flex-10 height_100 layout-row layout-align-center-center">
            <button
              className={`flex-none layout-row layout-align-center-center ${styles.send_button}`}
              style={btnStyle}
              onSubmit={this.reply}
            >
              <i className="flex-none fa fa-paper-plane-o" />
            </button>
          </div>
        </form>
        <div ref={(el) => { this.el = el }} />
      </div>
    )

    return (
      <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${styles.convo_wrapper}`}>
        <div
          className={`${styles.summary_wrapper}
          flex-100 layout-row layout-wrap layout-align-start-center `}
          onClick={this.toggleDetails}
        >
          <div className="flex-70 layout-wrap layout-row layout-align-start-center">
            <div className="flex-5" />
            {t('bookconf:shipmentReference')}:
            <div className="flex-5" />
            <b>
              {conversation.shipmentRef}
            </b>
          </div>
          <div
            className="flex-30 layout-align-center-center layout-row"
          >
            <h4 className="flex-none no_m">{t('bookconf:showDetails')}</h4>
            <div className="flex-5" />
            { showDetails
              ? <i className="fa fa-times clip" style={btnStyle} />
              : <i className="fa fa-info clip" style={btnStyle} /> }
          </div>
        </div>
        <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${styles.messageView}`}>
          { showDetails ? detailView : messageView }
        </div>
      </div>
    )
  }
}

Conversation.propTypes = {
  sendMessage: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired,
  conversation: PropTypes.shape({
    messages: PropTypes.array
  }).isRequired,
  theme: PropTypes.theme,
  shipment: PropTypes.shipment,
  user: PropTypes.user.isRequired,
  tenant: PropTypes.tenant.isRequired,
  clients: PropTypes.arrayOf(PropTypes.client),
  shipmentRef: PropTypes.string
}

Conversation.defaultProps = {
  theme: null,
  clients: null,
  shipment: null,
  shipmentRef: ''
}

export default withNamespaces(['account', 'bookconf'])(Conversation)
