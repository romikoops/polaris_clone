import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ShipmentContactsBox.scss';
// import {v4} from 'node-uuid';
// import { RoundButton } from '../RoundButton/RoundButton';
import defs from '../../styles/default_classes.scss';

export class ShipmentContactsBox extends Component {
    constructor(props) {
        super(props);
        this.state = {};
        this.removeNotifyee = this.removeNotifyee.bind(this);
    }

    removeNotifyee(not) {
        this.props.removeNotifyee(not);
    }
    render() {
        const { shipper, consignee, notifyees, theme } = this.props;
        const textStyle = {
            background:
                theme && theme.colors
                    ? '-webkit-linear-gradient(left, ' +
                      theme.colors.primary +
                      ',' +
                      theme.colors.secondary +
                      ')'
                    : 'black'
        };
        const notifyeeContacts = notifyees && notifyees.map((notifyee, i) => (
            (notifyee + i).toString()
        ));
        const shipperContact = shipper.toString();
        const consigneeContact = consignee.toString();
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
                    <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-start-start">
                        <div className={`${styles.contact_header} flex-100 layout-row layout-align-start-center`}>
                            <div className="flex-75 layout-row layout-align-start-center">
                                <i className="fa fa-user flex-none" style={textStyle}></i>
                                <p className="flex-none">Shipper</p>
                            </div>
                        </div>
                        {shipperContact}
                    </div>
                    <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-start-start">
                        <div className={`${styles.contact_header} flex-100 layout-row layout-align-start-center`}>
                            <div className="flex-75 layout-row layout-align-start-center">
                                <i className="fa fa-user flex-none" style={textStyle}></i>
                                <p className="flex-none">Consignee</p>
                            </div>
                        </div>
                        {consigneeContact}
                    </div>
                    <div className="flex-100 layout-row layout-wrap">
                        <div className="flex-100 layout-row layout-align-start-center">
                            <div
                                className={` ${
                                    styles.contact_header
                                } flex-50 layout-row layout-align-start-center`}
                            >
                                <i
                                    className="fa fa-users flex-none"
                                    style={textStyle}
                                />
                                <p className="flex-none"> Notifyees</p>
                            </div>
                        </div>
                        {notifyeeContacts}
                    </div>
                </div>
            </div>
        );
    }
}

ShipmentContactsBox.propTypes = {
    theme: PropTypes.object,
    shipper: PropTypes.object,
    consignee: PropTypes.object,
    notifyees: PropTypes.object
};
