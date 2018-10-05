import React, { Component } from 'react'
import { CSSTransition } from 'react-transition-group'
import PropTypes from 'prop-types'
import Alert from '../Alert/Alert'

class FlashMessages extends Component {
  constructor (props) {
    super(props)
    this.state = { messages: props.messages }
    this.addMessage = this.addMessage.bind(this)
    this.removeMessage = this.removeMessage.bind(this)
  }

  addMessage (message) {
    const { messages } = this.state
    messages.push(message)
    this.setState({ messages })
  }

  removeMessage (message) {
    const { messages } = this.state
    const index = messages.indexOf(message)
    messages.splice(index, 1)
    this.setState({ messages })
  }

  render () {
    const alerts = this.state.messages.map((message, i) => (
      // eslint-disable-next-line react/no-array-index-key
      <Alert key={i} message={message} onClose={this.removeMessage} timeout={10000} />
    ))

    return (
      <div style={{ zIndex: 9999 }} >
        <CSSTransition
          transitionName="alerts"
          transitionEnter={false}
          transitionLeaveTimeout={1000}
        >
          <div>{alerts}</div>
        </CSSTransition>
      </div>
    )
  }
}

FlashMessages.propTypes = {
  messages: PropTypes.arrayOf(PropTypes.string).isRequired
}

export default FlashMessages
