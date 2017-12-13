import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { AdminShipmentRow, AdminAddressTile} from './';
import styles from './Admin.scss';
import {v4} from 'node-uuid';
export class AdminClientView extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, clientData, hubs} = this.props;
        if (!clientData) {
            return '';
        }
        const { client, shipments, locations} = clientData;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        // const hubTiles = [];
        const shipRows = [];
        shipments.forEach((ship) => {
            // const shipKeys = [];
            // ship.schedule_set.forEach(ss => {

            // })
            // hubTiles.push( <AdminHubTile hub={hubs[ship]})
            shipRows.push( <AdminShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment}  client={client}/>);
        });
        const locationArr = locations.map((loc) => {
            return <AdminAddressTile key={v4()} address={loc} theme={theme} client={client}/>;
        });
        console.log(hubs);
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>Client Overview</p>
                    <div className="flex-40 layout-row layout-align-space-around-center">
                        <h2 className="flex-none"> {client.first_name} </h2>
                        <h2 className="flex-none"> {client.last_name} </h2>
                    </div>
                </div>

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Shipments</p>
                    </div>
                    {shipRows}
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Locations</p>
                    </div>
                    {locationArr}
                </div>
            </div>
        );
    }
}
AdminClientView.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    clientData: PropTypes.array
};
