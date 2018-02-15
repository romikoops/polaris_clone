import React, { Component } from 'react';
import styles from './Messaging.scss';
import { moment } from '../../constants';
import { Price } from '../Price/Price';
import { Tooltip } from '../Tooltip/Tooltip';
export class MessageShipmentData extends Component {
    constructor(props) {
        super(props);
        this.state = {
            working: true
        };
        this.onChangeFunc = this.onChangeFunc.bind(this);
    }
    onChangeFunc(optionsSelected) {
        const nameKey = this.props.name;
        this.props.onChange(nameKey, optionsSelected);
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
        return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`;
    }

    render() {
        const { theme, shipmentData, user, closeInfo } = this.props;
        if (!shipmentData) {
            return '';
        }
        const { hubs, schedules, shipment } = shipmentData;
        const total = parseFloat(shipment.total_price, 10);
        const { startHub, endHub } = hubs;
        const route = schedules[0];
        const gradientFontStyle = {
            background:
                theme && theme.colors
                    ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${
                        theme.colors.secondary
                    })`
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
        return(
            <div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.data_overlay}`}>
                <div className={`flex-100 layout-row layout-wrap ${styles.data_box}`}>
                    <div
                        className={`flex-100 layout-row layout-align-center-center ${
                            styles.top_row
                        }`}
                    >
                        <div
                            className={`flex-100 layout-row layout-align-start-center ${
                                styles.hubs_row
                            }`}
                        >
                            <div className={` flex-40 ${styles.header_hub}`}>
                                <div className="flex-100 layout-row">
                                    <div className="flex-15 layout-row layout-align-center-center">
                                        <i
                                            className={`fa fa-map-marker clip ${
                                                styles.map_marker
                                            }`}
                                            style={gradientFontStyle}
                                        />
                                    </div>
                                    <h4 className="flex-85"> {startHub.name} </h4>
                                </div>
                            </div>
                            <div className={` flex ${styles.connection_graphics}`}>
                                <div className="flex-none layout-row layout-align-center-center">
                                    {this.switchIcon(route)}
                                </div>
                                <div style={dashedLineStyles} />
                            </div>
                            <div className={` flex-40 ${styles.header_hub}`}>
                                <div className="flex-100 layout-row">
                                    <div className="flex-15 layout-row layout-align-center-center">
                                        <i className={`fa fa-flag-o clip ${styles.flag}`} style={gradientFontStyle}/>
                                    </div>
                                    <h4 className="flex-85"> {endHub.name} </h4>
                                </div>
                            </div>
                        </div>

                    </div>
                    <div className="flex-100 layout-row layout-align-center-center layout-wrap">
                        <div className="flex-50 layout-wrap layout-row layout-align-center-center">
                            <div className="flex-100 layout-row layout-align-center">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                    Pickup Date
                                </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-center">
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
                        <div className="flex-50 layout-wrap layout-row layout-align-center-center">
                            <div className="flex-100 layout-row layout-align-center">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                    {' '}
                                    Date of Departure
                                </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-center">
                                <p className={`flex-none ${styles.sched_elem}`}>
                                    {' '}
                                    {moment(route.etd).format(
                                        'YYYY-MM-DD'
                                    )}{' '}
                                </p>
                                <p className={`flex-none ${styles.sched_elem}`}>
                                    {' '}
                                    {moment(route.etd).format('HH:mm')}{' '}
                                </p>
                            </div>
                        </div>
                        <div className="flex-50 layout-wrap layout-row layout-align-center-center">
                            <div className="flex-100 layout-row layout-align-center">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                    {' '}
                                    ETA terminal
                                </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-center">
                                <p className={`flex-none ${styles.sched_elem}`}>
                                    {' '}
                                    {moment(route.eta).format(
                                        'YYYY-MM-DD'
                                    )}{' '}
                                </p>
                                <p className={`flex-none ${styles.sched_elem}`}>
                                    {' '}
                                    {moment(route.eta).format('HH:mm')}{' '}
                                </p>
                            </div>
                        </div>
                        <div className="flex-100 flex-gt-sm-50 layout-wrap layout-row layout-align-space-between-center">
                            <div className="flex-100 layout-row layout-align-center">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                    Shipment Type:
                                </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-center">
                                <p className="flex-none"> {shipment.load_type === 'cargo_item' ? 'LCL' : 'FCL'} </p>
                            </div>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">

                        <div className="flex-100 flex-gt-sm-50 layout-wrap layout-row layout-align-space-between-center">
                            <div className="flex-100 layout-row layout-align-center">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                    IncoTerm:
                                </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-center">
                                <p className="flex-none"> {shipment.incoterm} </p>
                            </div>
                        </div>
                        <div className="flex-100 flex-gt-sm-50 layout-wrap layout-row layout-align-space-between-center">
                            <div className="flex-100 layout-row layout-align-center">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                   MoT:
                                </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-center">
                                <p className="flex-none"> {route.mode_of_transport} </p>
                            </div>
                        </div>
                        <div className="flex-100 flex-gt-sm-50 layout-wrap layout-row layout-align-space-between-center">
                            <div className="flex-100 layout-row layout-align-center">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                    Pre-carrage:
                                </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-center">
                                <p className="flex-none"> {shipment.has_pre_carriage ? 'Yes' : 'No'} </p>
                            </div>
                        </div>
                        <div className="flex-100 flex-gt-sm-50 layout-wrap layout-row layout-align-space-between-center">
                            <div className="flex-100 layout-row layout-align-center">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                    On-carriage:
                                </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-center">
                                <p className="flex-none"> {shipment.has_on_carriage ? 'Yes' : 'No'}  </p>
                            </div>
                        </div>
                    </div>
                    <div
                        className={`flex-100 layout-row layout-align-center-center ${
                            styles.load_type
                        }`}
                    >
                        <div
                            className={`${
                                styles.tot_price
                            } flex-none layout-row layout-align-space-between-center`}
                            style={gradientFontStyle}
                        >
                            <p>Total Price:</p>{' '}
                            <Tooltip theme={theme} icon="fa-info-circle" color="white" text="total_price" />
                            <Price value={total} user={user}/>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-align-center-center">
                            <div className="flex-33 layout-row layout-align-space-around-center" onClick={closeInfo}>
                                <i className="flex-none fa fa-angle-double-up"></i>
                                <div className="flex-5"></div>
                                <p className="flex-none">Hide</p>
                                <div className="flex-5"></div>
                                <i className="flex-none fa fa-angle-double-up"></i>
                            </div>
                        </div>
                </div>
            </div>
        );
    }
}
