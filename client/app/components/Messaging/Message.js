import React, { Component } from 'react';
import styles from './Messaging.scss';
import { moment } from '../../constants';
import styled from 'styled-components';
export class Message extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const  { message, theme, tenant, user } = this.props;
        // const isAdmin = user.role_id === 1;
        const messageStyle = message.sender_id === message.user_id ? styles.user_style : styles.tenant_style;
        const UserMessage = styled.div`
            background: #fff;
            border: 2px solid ${theme.colors.secondary};
            :after {
                content: '';
                position: absolute;
                right: 0;
                top: 75%;
                width: 0;
                height: 0;
                border: 20px solid transparent;
                border-left-color: ${theme.colors.secondary};
                border-right: 0;
                border-bottom: 0;
                margin-top: -10px;
                margin-right: -20px;
              }
        `;
        const AdminMessage = styled.div`
            background-color: #fff;
            border: 2px solid ${theme.colors.brightPrimary};
            :after {
                content: '';
                position: absolute;
                left: 0;
                top: 75%;
                width: 0;
                height: 0;
                border: 20px solid transparent;
                border-right-color: ${theme.colors.brightPrimary};
                border-left: 0;
                border-bottom: 0;
                margin-top: -10px;
                margin-left: -20px;
              }
        `;
        const meta = message.sender_id === user.data.id ?
            <p className={`flex-none ${styles.timestamp}`}>You @ {moment.unix(message.timestamp).format('lll')}</p> :
            <p className={`flex-none ${styles.timestamp}`}>{tenant.data.name} Admin @ {moment.unix(message.timestamp).format('lll')}</p>;
        // const msgShadow = message.sender_id === message.user_id ? {boxShadow: `5px 4px 13px 0px ${theme.colors.primary}50`} : {boxShadow: `5px 4px 13px 0px ${theme.colors.secondary}50`};
        // const msgBg = message.sender_id === message.user_id ?
        //  {borderColor: `${theme.colors.secondary}`, borderLeftColor: `${theme.colors.secondary}`, color: 'white'} :
        //  {background: `${theme.colors.primary}`, borderRightColor: `${theme.colors.primary}`, color: 'white'};
        const Comp = message.sender_id === user.data.id ? UserMessage : AdminMessage;
        return (
            <div className={`flex-100 layout-row ${styles.message_wrapper}`}>
                {message.sender_id === message.user_id ? <div className="flex-10"></div> : <div className="flex-5"></div> }
                <Comp className={`flex-none layout-row layout-align-start-center layout-wrap ${messageStyle} ${styles.message_inner}`}>
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.message_title}`}>
                        <p className="flex-none">{message.title}</p>
                        {meta}
                    </div>
                    <div className={`flex-100 layout-row layout-align-start-center ${styles.message_text}`}>
                        <p className="flex-none">{message.message}</p>
                    </div>
                </Comp>
            </div>
        );
    }
}
