import React, { Component } from 'react';
import styles from './Messaging.scss';
// import { moment } from '../../constants';
export class ConvoTile extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const  { theme, conversation, viewConvo, convoKey } = this.props;
        console.log(theme);
        return (
            <div className={`flex-100 layout-row layout-align-start-start  ${styles.convo_tile_wrapper}`} onClick={() => viewConvo(conversation)}>
                <div className={`flex layout-row layout-align-center-start pointy layout-wrap  ${styles.convo_tile}`}>
                    <div className="flex-95 layout-row layout-align-start-center">
                        <p className="flex-none">Shipment: {convoKey}</p>
                    </div>
                    {/* <div className="flex-100 layout-row layout-align-start-center">
                        <p className="flex-none">Last Updated: {moment.unix(conversation.messages[0].timestamp).format('lll')}</p>
                    </div>*/}
                 </div>
            </div>
        );
    }
}
