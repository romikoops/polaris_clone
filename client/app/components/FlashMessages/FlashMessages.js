import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Alert } from '../Alert/Alert';
import { CSSTransitionGroup } from 'react-transition-group';
export class FlashMessages extends Component {
    constructor(props) {
        super(props);
        this.state = { messages: props.messages };
    }

    addMessage(message) {
        const messages = this.state.messages;
        message.push(message);
        this.setState({ messages: messages });
    }

    removeMessage(message) {
        const index = this.state.messages.indexOf(message);
        const messages = this.state.messages.splice(index, 1);
        this.setState({ messages: messages });
    }

    render() {
        const message = {type: 'error', text: this.props.messages, id: 1};
        // const alerts = this.state.messages.map( message =>
        // );
        const alerts = [
            <Alert key={ message.id } message={ message }
            onClose={ () => this.removeMessage(message) } />
        ];

        return(
            <CSSTransitionGroup
                transitionName="alerts"
                transitionEnter={false}
                transitionLeaveTimeout={500}>
                { alerts }
            </CSSTransitionGroup>
        );
    }
}

FlashMessages.PropTypes = {
    messages: PropTypes.array.isRequired
};
