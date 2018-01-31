import React, { Component } from 'react';
import styles from './Messaging.scss';
import { Message, MessageShipmentData } from './';
import {v4} from 'node-uuid';
export class Conversation extends Component {
    constructor(props) {
        super(props);
        this.state = {
            message: '',
            title: '',
            showDetails: false
        };
        this.handleReplyChange = this.handleReplyChange.bind(this);
        this.reply = this.reply.bind(this);
        this.toggleDetails = this.toggleDetails.bind(this);
    }
    handleReplyChange(ev) {
        const { name, value } = ev.target;
        this.setState({[name]: value});
    }
    toggleDetails() {
        this.setState({showDetails: !this.state.showDetails});
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
        const  { conversation, theme, shipment, user, tenant, clients } = this.props;
        const { message, title, showDetails } = this.state;

        console.log(clients);
        const isAdmin = user.data.role_id === 1;
        const messages = isAdmin ?
            conversation.messages.map((msg) => {
                const client = clients.filter(c => c.id === msg.user_id)[0];
                // debugger;
                return <Message tenant={tenant} user={user} message={msg} client={client} theme={theme} key={v4()}/>;
            }) :
            conversation.messages.map((msg) => {
                // debugger;
                return <Message tenant={tenant} user={user} message={msg} theme={theme} key={v4()}/>;
            });
        // const summStyle = showDetails ? styles.show_details : styles.hide_details;

        const summWrapStyle = showDetails ? styles.wrapper_open : styles.wrapper_closed;
        const btnStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const messageView = (
            <div className="flex-100 layout-column layout-align-start-start">
                <div className={`flex-70 layout-row layout-align-start-start layout-wrap ${styles.message_scroll}`}>
                    {messages}
                </div>
                <form className={`${styles.msg_form} flex-30 width_100 layout-row layout-align-start-center`} onSubmit={this.reply}>
                    <div className="flex-90 layout-row layout-align-center-space-around height_100 layout-wrap">
                        <div className="flex-95 layout-row layout-align-center-center input_box">
                            <input type="text" name="title" className={`flex-90 ${styles.text_input}`} placeholder="Type your message title here...." value={title} onChange={this.handleReplyChange}/>
                        </div>
                        <div className="flex-95 layout-row layout-align-center-center">
                            <textarea name="message" placeholder="Type your message text here...." id="" className={`flex-90 ${styles.text_area}`} value={message} cols="30" rows="5" onChange={this.handleReplyChange}></textarea>
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
        return (
            <div className={`flex-100 layout-column layout-align-start-start ${styles.convo_wrapper}`}>
                <div className={`flex-10 layout-row layout-wrap layout-align-start-center ${summWrapStyle} ${styles.summary_wrapper}`}>
                    <div className="flex-100 layout-row layout-align-start-center" onClick={this.toggleDetails}>
                        <div className="flex-5"></div>
                        <p className="flex-none">Shipment: {conversation.shipmentRef}</p>
                        <div className="flex"></div>
                        <div className="flex-10 layout-row layout-align-center-center" >
                            <i className="fa fa-info clip" style={btnStyle}></i>
                        </div>
                    </div>
                    {/* <div className={`${summStyle} flex-none layout-row layout-wrap layout-align-start-center ${styles.summary}`}>
                        <MessageShipmentData theme={theme} shipmentData={shipment} user={user} closeInfo={this.toggleDetails}/>
                    </div>*/}
                </div>
                <div className="flex-90 layout-column layout-align-start-start">
                    { showDetails ? <MessageShipmentData theme={theme} shipmentData={shipment} user={user} closeInfo={this.toggleDetails}/> : messageView }
                </div>

            </div>
        );
    }
}
