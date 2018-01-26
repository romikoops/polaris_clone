import React, { Component } from 'react';
import styles from './Messaging.scss';
import { moment } from '../../constants';
export class Message extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const  { message, theme } = this.props;
        const messageStyle = message.sender_id === message.user_id ? styles.user_style : styles.tenant_style;
        // const msgShadow = message.sender_id === message.user_id ? {boxShadow: `5px 4px 13px 0px ${theme.colors.primary}50`} : {boxShadow: `5px 4px 13px 0px ${theme.colors.secondary}50`};
        const msgBg = message.sender_id === message.user_id ? {background: `${theme.colors.primary}`, color: 'white'} : {background: `${theme.colors.secondary}`, color: 'white'};
        return (
            <div className={`flex-100 layout-row ${styles.message_wrapper}`}>
                {message.sender_id === message.user_id ? <div className="flex-5"></div> : ''}
                <div className={`flex-none layout-row layout-align-start-center layout-wrap ${messageStyle} ${styles.message_inner}`} style={msgBg}>
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.message_title}`}>
                        <p className="flex-none">{message.title}</p>
                        <p className={`flex-none ${styles.timestamp}`}>{moment.unix(message.timestamp).format('lll')}</p>
                    </div>
                    <div className={`flex-100 layout-row layout-align-start-center ${styles.message_text}`}>
                        <p className="flex-none">{message.message}</p>
                    </div>
                </div>
            </div>
        );
    }
}
