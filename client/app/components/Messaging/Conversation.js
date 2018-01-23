import React, { Component } from 'react';
import styles from './Messaging.scss';
import { Message } from './Message';
export class Conversation extends Component {
    constructor(props) {
        super(props);
        this.state = {
            message: '',
            title: ''
        };
        this.handleReplyChange = this.handleReplyChange.bind(this);
        this.reply = this.reply.bind(this);
    }
    handleReplyChange(ev) {
        const { name, value } = ev.target;
        this.setState({[name]: value});
    }
    reply() {
        const { message, title } = this.state;
        const { sendMessage, conversation } = this.props;
        const msg = {
            title,
            message,
            shipmentRef: conversation.messages[0].shipmentRef
        };
        sendMessage(msg);
    }

    render() {
        const  { conversation, theme } = this.props;
        const { message, title } = this.state;
        const messages = conversation.messages.map((msg) => {
            return <Message message={msg} theme={theme} />;
        });
        const btnStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return (
            <div className={`flex-100 layout-column layout-align-start-start ${styles.convo_wrapper}`}>
                <div className={`flex-80 layout-row layout-align-start-start layout-wrap ${styles.message_scroll}`}>
                    { messages }
                </div>
                <form className="flex-20 width_100 layout-row layout-align-start-center" onSubmit={this.reply}>
                    <div className="flex-90 layout-row layout-align-center-center layout-wrap">
                        <div className="flex-100 layout-row layout-align-center-center input_box_full">
                            <input type="text" name="title" value={title} onChange={this.handleReplyChange}/>
                        </div>
                        <div className="flex-100 layout-row layout-align-center-center">
                            <textarea name="message" id="" className={`flex-100 ${styles.text_area}`} value={message} cols="30" rows="5" onChange={this.handleReplyChange}></textarea>
                        </div>
                    </div>
                    <div className="flex-10 height_100 layout-row layout-align-center-center">
                        <button className={`flex-none layout-row layout-align-center-center ${styles.send_button}`} style={btnStyle} onSubmit={this.reply}>
                            <i className="flex-none fa fa-paper-plane-o"></i>
                        </button>
                    </div>
                </form>
            </div>
        );
    }
}
