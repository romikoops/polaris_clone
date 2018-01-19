import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './AdminShipmentRow.scss';
import { moment } from '../../constants';
import {v4} from 'node-uuid';
export class AdminShipmentRow extends Component {
    constructor(props) {
        super(props);
        this.selectShipment = this.selectShipment.bind(this);
        this.handleDeny = this.handleDeny.bind(this);
        this.handleAccept = this.handleAccept.bind(this);
        this.handleIgnore = this.handleIgnore.bind(this);
    }
    switchIcon(sched) {
        let icon;
        switch (sched.mode_of_transport) {
            case 'ocean':
                icon = <i className="fa fa-ship" />;
                break;
            case 'air':
                icon = <i className="fa fa-plane" />;
                break;
            case 'train':
                icon = <i className="fa fa-train" />;
                break;
            default:
                icon = <i className="fa fa-ship" />;
                break;
        }
        return icon;
    }

    dashedGradient(color1, color2) {
        return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${
            color1
        }, ${color2})`;
    }
    selectShipment() {
        const {shipment, handleSelect} = this.props;
        handleSelect(shipment);
    }
    handleDeny() {
        const {shipment, handleAction} = this.props;
        handleAction(shipment.id, 'decline');
    }

    handleAccept() {
        const {shipment, handleAction} = this.props;
        handleAction(shipment.id, 'accept');
    }

    handleIgnore() {
        const {shipment, handleAction} = this.props;
        handleAction(shipment.id, 'ignore');
    }
    render() {
        const { theme, shipment, hubs} = this.props;
        if (shipment.schedule_set.length < 1) {
            debugger;
            return '';
        }
        const hubKeys = shipment.schedule_set[0].hub_route_key.split('-');
        if (!hubs[hubKeys[0]] || !hubs[hubKeys[1]]) {
            debugger;
            // ;
            return '';
        }
        const schedule = {};
        const originHub = hubs[hubKeys[0]].data;
        const destHub = hubs[hubKeys[1]].data;
        const gradientFontStyle = {
            background:
                theme && theme.colors
                    ? `-webkit-linear-gradient(left, ${
                        theme.colors.brightPrimary
                    }, ${theme.colors.brightSecondary})`
                    : 'black'
        };
        const dashedLineStyles = {
            marginTop: '6px',
            height: '2px',
            width: '100%',
            background:
                theme && theme.colors
                    ? this.dashedGradient(
                        theme.colors.primary,
                        theme.colors.secondary
                    )
                    : 'black',
            backgroundSize: '16px 2px, 100% 2px'
        };
        const btnsRow = (
            <div className={`flex-40 layout-row layout-align-space-between-start layout-wrap ${styles.btn_row}`}>
                <div className={`flex-40 layout-row layout-align-center-center ${styles.edit}`} onClick={this.handleEdit}>
                    <i className="flex-none fa fa-pencil"></i>
                    <p className="flex-none">Edit</p>
                </div>
                <div className={`flex-40 layout-row layout-align-center-center ${styles.grant}`} onClick={this.handleAccept}>
                    <i className="flex-none fa fa-check"></i>
                    <p className="flex-none">Accept</p>
                </div>
                <div className={`flex-none layout-row layout-align-center-center ${styles.close_x}`} onClick={this.handleIgnore}>
                    <i className="fa fa-close"></i>
                </div>
            </div>
        );
        return (
            <div
                key={v4()}
                className={`flex-100 layout-row pointy ${styles.route_result}`}

            >
                <div className="flex-100 layout-row layout-wrap">
                    <div
                        className={`flex-40 layout-row layout-align-start-center layout-wrap ${
                            styles.top_row
                        }`}
                        onClick={this.selectShipment}
                    >

                        <div className={`${styles.header_hub}`}>
                            <i
                                className={`fa fa-map-marker ${
                                    styles.map_marker
                                }`}
                            />
                            <div className="flex-100 layout-row">
                                <h4 className="flex-100"> {originHub.name} </h4>
                            </div>
                            <div className="flex-100">
                                <p className="flex-100">
                                    {' '}
                                    {originHub.hub_code
                                        ? originHub.hub_code
                                        : ''}{' '}
                                </p>
                            </div>
                        </div>
                        <div className={`${styles.connection_graphics}`}>
                            <div className="flex-none layout-row layout-align-center-center">
                                {this.switchIcon(schedule)}
                            </div>
                            <div style={dashedLineStyles} />
                        </div>
                        <div className={`${styles.header_hub}`}>
                            <i className={`fa fa-flag-o ${styles.flag}`} />
                            <div className="flex-100 layout-row">
                                <h4 className="flex-100"> {destHub.name} </h4>
                            </div>
                            <div className="flex-100">
                                <p className="flex-100">
                                    {' '}
                                    {destHub.hub_code
                                        ? destHub.hub_code
                                        : ''}{' '}
                                </p>
                            </div>
                        </div>
                        <div className={`flex-100 layout-row layout-align-start-end ${styles.ref_row}`}>
                            <p className="flex-none">Ref: {shipment.imc_reference}</p>
                        </div>
                    </div>
                    <div className={`flex-60 layout-row layout-align-start-center layout-wrap ${styles.right_row}`}>
                        <div className={`flex-100 layout-row layout-align-start-start ${styles.action_bar}`}>
                            <div className={`flex-60 layout-row layout-align-start-center layout-wrap ${styles.user_info}`}  onClick={this.selectShipment}>
                                <i className={`flex-none fa fa-user ${styles.flag}`} style={gradientFontStyle}></i>
                                <p className="flex-none"> {shipment.clientName} </p>
                                {/* <p className="flex-none"> {client.last_name} </p>*/}
                            </div>
                            { shipment.status === 'requested' ? btnsRow : ''}
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center"  onClick={this.selectShipment}>
                            <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                                <div className="flex-100 layout-row">
                                    <h4
                                        className={styles.date_title}

                                    >
                                      Pickup Date
                                    </h4>
                                </div>
                                <div className="flex-100 layout-row">
                                    <p className={`flex-none ${styles.sched_elem}`}>
                                        {' '}
                                        {moment(this.props.pickupDate).format(
                                            'YYYY-MM-DD'
                                        )}{' '}
                                    </p>
                                    <p className={`flex-none ${styles.sched_elem}`}>
                                        {' '}
                                        {moment(this.props.pickupDate).format(
                                            'HH:mm'
                                        )}{' '}
                                    </p>
                                </div>
                            </div>
                            <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                                <div className="flex-100 layout-row">
                                    <h4
                                        className={styles.date_title}

                                    >
                                        {' '}
                                      Date of Departure
                                    </h4>
                                </div>
                                <div className="flex-100 layout-row">
                                    <p className={`flex-none ${styles.sched_elem}`}>
                                        {' '}
                                        {moment(schedule.eta).format(
                                            'YYYY-MM-DD'
                                        )}{' '}
                                    </p>
                                    <p className={`flex-none ${styles.sched_elem}`}>
                                        {' '}
                                        {moment(schedule.eta).format('HH:mm')}{' '}
                                    </p>
                                </div>
                            </div>
                            <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                                <div className="flex-100 layout-row">
                                    <h4
                                        className={styles.date_title}

                                    >
                                        {' '}
                                      ETA terminal
                                    </h4>
                                </div>
                                <div className="flex-100 layout-row">
                                    <p className={`flex-none ${styles.sched_elem}`}>
                                        {' '}
                                        {moment(schedule.eta).format(
                                            'YYYY-MM-DD'
                                        )}{' '}
                                    </p>
                                    <p className={`flex-none ${styles.sched_elem}`}>
                                        {' '}
                                        {moment(schedule.eta).format('HH:mm')}{' '}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}
AdminShipmentRow.propTypes = {
    theme: PropTypes.object,
    schedule: PropTypes.object,
    handleSelect: PropTypes.func,
    hubs: PropTypes.object,
};
