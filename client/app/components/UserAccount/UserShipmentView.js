import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin/Admin.scss';
import {ContainerDetails} from '../ContainerDetails/ContainerDetails';
import {CargoItemDetails} from '../CargoItemDetails/CargoItemDetails';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import {v4} from 'node-uuid';
import { moment } from '../../constants';
// import { RoundButton } from '../RoundButton/RoundButton';
export class UserShipmentView extends Component {
    constructor(props) {
        super(props);
    }


    render() {
        console.log(this.props);
        const { theme, hubs, shipmentData, user } = this.props;

        if (!shipmentData || !hubs || !user) {
            return <h1>NO DATA</h1>;
        }
        const { contacts, shipment, documents, cargoItems, containers, schedules } = shipmentData;
        // debugger;
        const hubKeys = schedules[0].hub_route_key.split('-');
        const hubsObj = {startHub: {}, endHub: {}};
        hubs.forEach(c => {
            if (String(c.data.id) === hubKeys[0]) {
                hubsObj.startHub = c;
            }
            if (String(c.data.id) === hubKeys[1]) {
                hubsObj.endHub = c;
            }
        });
        const createdDate = shipment ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A') :  moment().format('DD-MM-YYYY | HH:mm A');
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const nArray = [];
        const cargoView = [];
        const docView = [];
        let shipperContact = '';
        let consigneeContact = '';
        if (contacts) {
            contacts.forEach(n => {
                if (n.type === 'notifyee') {
                    nArray.push(
                        <div key={v4()} className="flex-33 layout-row">
                            <div className="flex-15 layout-column layout-align-start-center">
                                <i className={` ${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle}></i>
                            </div>
                            <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                                <p className="flex-100">Notifyee</p>
                                <p className={` ${styles.address} flex-100`}>
                                    {n.contact.first_name} {n.contact.last_name} <br/>
                                    {n.location.street} {n.location.street_number} <br/>
                                    {n.location.zip_code} {n.location.city} <br/>
                                    {n.location.country}
                                </p>
                            </div>
                        </div>
                    );
                }
                if (n.type === 'shipper') {
                    shipperContact = (
                        <div className="flex-33 layout-row">
                            <div className="flex-15 layout-column layout-align-start-center">
                                <i className={`${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle}></i>
                            </div>
                            <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                                <p className="flex-100">Shipper</p>
                                <p className={`${styles.address} flex-100`}>
                                    {n.contact.first_name} {n.contact.last_name} <br/>
                                    {n.location.street} {n.location.street_number} <br/>
                                    {n.location.zip_code} {n.location.city} <br/>
                                    {n.location.country}
                                </p>
                            </div>
                        </div>
                    );
                }
                if (n.type === 'consignee') {
                    consigneeContact = (
                        <div className="flex-33 layout-row">
                            <div className="flex-15 layout-column layout-align-start-center">
                                <i
                                    className={` ${
                                        styles.icon
                                    } fa fa-envelope-open-o flex-none`}
                                    style={textStyle}
                                />
                            </div>
                            <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                                <p className="flex-100">Consignee</p>
                                <p
                                    className={` ${
                                        styles.address
                                    } flex-100`}
                                >
                                    {n.contact.first_name}{' '}
                                    {n.contact.last_name} <br />
                                    {n.location.street}{' '}
                                    {n.location.street_number}{' '}
                                    <br />
                                    {n.location.zip_code}{' '}
                                    {n.location.city} <br />
                                    {n.location.country}
                                </p>
                            </div>
                        </div>
                    );
                }
            });
        }
        if (containers) {
            containers.forEach((cont, i)=> {
                const offset = i % 3 !== 0 ? 'offset-5' : '';
                cargoView.push(
                    <div key={v4()} className={`flex-30 ${offset} layout-row layout-align-center-center`}>
                        <ContainerDetails item={cont} index={i} />
                    </div>
                );
            });
        }
        if (cargoItems) {
            cargoItems.forEach((ci, i)=> {
                const offset = i % 3 !== 0 ? 'offset-5' : '';
                cargoView.push(
                    <div key={v4()} className={`flex-30 ${offset} layout-row layout-align-center-center`}>
                        <CargoItemDetails item={ci} index={i} />
                    </div>
                );
            });
        }
        if (documents) {
            documents.forEach((ci)=> {
                docView.push(<p> {ci.url}</p>);
            });
        }
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <div className="flex-60 layout-row layout-wrap layout-align-start-start">
                        <p className={` ${styles.sec_title_text_normal} flex-none`} >Shipment status:</p>
                        <p className={` ${styles.sec_title_text} flex-none offset-5`} style={textStyle} >{ shipment.status }</p>
                    </div>
                </div>
                <div className={`flex-100 layout-row layout-align-start ${styles.b_ref}`}>
                    Booking Reference: {shipment.imc_reference}
                </div>
                <RouteHubBox hubs={hubsObj} route={schedules} theme={theme}/>
                <div className={`${styles.b_summ} flex-100`}>
                    <div className={`${styles.b_summ_top} flex-100 layout-row`}>
                        { shipperContact }
                        { consigneeContact }
                        <div className="flex-33 layout-row layout-align-end">
                            <p> {createdDate} </p>
                        </div>
                    </div>
                    <div className="flex-100 layout-row"> {nArray} </div>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  >Cargo</p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                        { cargoView }
                    </div>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  >Documents</p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                        { docView }
                    </div>
                </div>
            </div>
        );
    }
}

UserShipmentView.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    shipmentData: PropTypes.object,
    clients: PropTypes.array,
    handleShipmentAction: PropTypes.func
};
