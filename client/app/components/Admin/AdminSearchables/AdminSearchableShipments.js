import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin.scss';
import { AdminShipmentRow } from '../';
import { UserShipmentRow } from '../../UserAccount';
import {v4} from 'node-uuid';
import Fuse from 'fuse.js';
export class AdminSearchableShipments extends Component {
    constructor(props) {
        super(props);
        this.state = {
            shipments: props.shipments
        };
        this.handleSearchChange = this.handleSearchChange.bind(this);
        this.handleClick = this.handleClick.bind(this);
        this.seeAll = this.seeAll.bind(this);
    }
    seeAll() {
        const {seeAll, adminDispatch} = this.props;
        if (seeAll) {
            seeAll();
        } else {
            adminDispatch.goTo('/admin/shipments');
        }
    }
    handleClick(shipment) {
        const {handleClick, adminDispatch} = this.props;
        if (handleClick) {
            handleClick(shipment);
        } else {
            adminDispatch.getShipment(shipment.id, true);
        }
    }
    handleSearchChange(event) {
        if (event.target.value === '') {
            this.setState({
                shipments: this.props.shipments
            });
            return;
        }
        const search = (keys) => {
            const options = {
                shouldSort: true,
                tokenize: true,
                threshold: 0.2,
                location: 0,
                distance: 50,
                maxPatternLength: 32,
                minMatchCharLength: 2,
                keys: keys
            };
            const fuse = new Fuse(this.props.shipments, options);
            console.log(fuse);
            return fuse.search(event.target.value);
        };

        const filteredShipments = search(['clientName', 'imc_reference', 'companyName', 'originHub', 'destinationHub']);

        this.setState({
            shipments: filteredShipments
        });
    }
    render() {
        const { hubs, theme, handleShipmentAction, title, userView, seeAll } = this.props;
        const { shipments } = this.state;
        let shipmentsArr;
        if (shipments) {
            shipmentsArr = shipments.map((ship) => {
                return  userView ?
                    <UserShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.handleClick} handleAction={handleShipmentAction} />
                    : <AdminShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.handleClick} handleAction={handleShipmentAction} />;
            });
        } else if (this.props.shipments) {
            shipmentsArr = shipments.map((ship) => {
                return  userView ?
                    <UserShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.handleClick} handleAction={handleShipmentAction} />
                    : <AdminShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.handleClick} handleAction={handleShipmentAction} />;
            });
        }
        const viewType = this.props.sideScroll ?
            (<div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
                <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
                    {shipmentsArr}
                </div>
            </div>) :
            (<div className="layout-row flex-100 layout-align-start-center ">
                <div className="layout-row flex-none layout-align-start-center layout-wrap">
                    {shipmentsArr}
                </div>
            </div>);
        return(
            <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.searchable}`}>
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.searchable_header}`}>
                    <div className="flex-none layput-row layout-align-start-center">
                        <p className="flex-none sub_header_text"> {title ? title : 'Shipments'}</p>
                    </div>
                    <div className={`${styles.input_box} flex-none layput-row layout-align-start-center`}>
                        <input
                            type="text"
                            name="search"
                            placeholder="Search Shipments"
                            onChange={this.handleSearchChange}
                        />
                    </div>
                </div>
                {viewType}
                { seeAll !== false ? (<div className="flex-100 layout-row layout-align-end-center">
                                    <div className="flex-none layout-row layout-align-center-center" onClick={this.seeAll}>
                                        <p className="flex-none">See all</p>
                                    </div>
                                </div>) : ''}
            </div>
        );
    }
}
AdminSearchableShipments.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};
