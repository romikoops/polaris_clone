import React, { Component } from 'react';
import { ConvoTile, Conversation } from '../../components/Messaging';
import { messagingActions } from '../../actions';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import styles from './MessageCenter.scss';
class MessageCenter extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedConvo: false
        };
        this.selectConvo = this.selectConvo.bind(this);
        this.sendMessage = this.sendMessage.bind(this);
    }
    componentDidUpdate() {
        if (!this.state.selectedConvo) {
            this.selectConvo(this.props.converstations[Object.keys(this.props.converstations)[0]]);
        }
    }
    selectConvo(conv) {
        conv.shipmentRef = conv.messages[0].shipmentRef;
        this.setState({selectedConvo: conv});
        const { messageDispatch } = this.props;
        messageDispatch.markConvoAsRead(conv);
        messageDispatch.fetchShipment(conv.shipmentRef);
    }
    sendMessage(msg) {
        const { messageDispatch } = this.props;
        messageDispatch.sendUserMessage(msg);
    }

    render() {
        const  { theme, close, messageDispatch, conversations } = this.props;
        if (!conversations) {
            return '';
        }
        const convoKeys = Object.keys(conversations);
        const convos = convoKeys.map((ms) => {
            return <ConvoTile theme={theme} conversation={conversations[ms]} convoKey={ms} viewConvo={this.selectConvo} />;
        });
        const selectedConvo = this.state.selectedConvo ? this.state.selectedConvo : conversations[convoKeys[0]];
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const messageView = selectedConvo ? <Conversation conversation={selectedConvo} theme={theme} messageDispatch={messageDispatch} sendMessage={this.sendMessage}/> : '';
        return (
            <div className={`flex-none layout-row layout-wrap layout-align-center-center ${styles.backdrop}`}>
                <div className={`flex-none ${styles.fade}`} onClick={() => close()}></div>
                <div className={`flex-none layout-column layout-align-start-start ${styles.message_center}`}>
                    <div className="flex-10 width_100 layout-row layout-align-start-center">
                        <h3 className="flex-none clip letter_3" style={textStyle}>Message Center</h3>
                    </div>
                    <div className="flex-90 width_100 layout-row layout-align-start-start">
                        <div className={`flex-30 layout-row layout-wrap layout-align-center-start ${styles.convo_list}`}>
                            {convos}
                        </div>
                        <div className={`flex-70 layout-column layout-align-start-start ${styles.message_list}`}>
                            {messageView}
                        </div>
                    </div>

                </div>
            </div>
        );
    }
}
function mapStateToProps(state) {
    const { users, authentication, tenant, messaging } = state;
    const { user, loggedIn } = authentication;
    const { conversations, unread } = messaging;
    return {
        user,
        users,
        conversations,
        tenant,
        theme: tenant.data.theme,
        loggedIn,
        unread
    };
}
function mapDispatchToProps(dispatch) {
    return {
        messageDispatch: bindActionCreators(messagingActions, dispatch)
    };
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(MessageCenter));
