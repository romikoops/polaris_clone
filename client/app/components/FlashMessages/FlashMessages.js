import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Alert } from '../Alert/Alert';
import { CSSTransitionGroup } from 'react-transition-group';
export class FlashMessages extends Component {
    constructor(props) {
        super(props);
        this.state = { messages: props.messages };
        this.addMessage = this.addMessage.bind(this);
        this.removeMessage = this.removeMessage.bind(this);
    }

    addMessage(message) {
        const messages = this.state.messages;
        messages.push(message);
        this.setState({ messages: messages });
    }

    removeMessage(message) {
        const messages = this.state.messages;
        const index = messages.indexOf(message);
        messages.splice(index, 1);
        this.setState({ messages: messages });
    }

    render() {
        const alerts = this.state.messages.map( (message, i) =>
            <Alert key={ i } message={ message } onClose={ this.removeMessage } />
        );

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

FlashMessages.propTypes = {
    messages: PropTypes.array.isRequired
};
