import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin/Admin.scss';
import {ContainerDetails} from '../ContainerDetails/ContainerDetails';
import {CargoItemDetails} from '../CargoItemDetails/CargoItemDetails';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import {v4} from 'node-uuid';
import { moment } from '../../constants';
import Select from 'react-select';

import '../../styles/select-css-custom.css';
import styled from 'styled-components';
import FileUploader from '../FileUploader/FileUploader';
import FileTile from '../FileTile/FileTile';
// import { RoundButton } from '../RoundButton/RoundButton';
export class UserShipmentView extends Component {
    constructor(props) {
        super(props);
        this.state = {
            fileType: {label: 'Packing Sheet', value: 'packing_sheet'},
            upUrl: this.props.shipmentData ? '/shipments/' + this.props.shipmentData.shipment.id + '/upload/packing_sheet' : ''
        };
        this.setFileType = this.setFileType.bind(this);
    }
    componentDidMount() {
        const { shipmentData, loading, userDispatch, user, match} = this.props;
        this.props.setNav('shipments');
        if (!shipmentData && !loading) {
            userDispatch.getShipment(user.data.id, match.params.id, false);
        }
    }
    setFileType(ev) {
        const shipmentId = this.props.shipmentData.shipment.id;
        const url = '/shipments/' + shipmentId + '/upload/' + ev.value;
        this.setState({fileType: ev, upUrl: url});
    }

    render() {
        console.log(this.props);
        const { theme, hubs, shipmentData, user, userDispatch } = this.props;

        if (!shipmentData || !hubs || !user) {
            return <h1>NO DATA</h1>;
        }
        const { contacts, shipment, documents, cargoItems, containers, schedules } = shipmentData;
        // ;
        const docOptions = [
            {label: 'Packing Sheet', value: 'packing_sheet'},
            {label: 'Commercial Invoice', value: 'commercial_invoice'},
            {label: 'Customs Declaration', value: 'customs_declaration'},
            {label: 'Customs Value Declaration', value: 'customs_value_declaration'},
            {label: 'EORI', value: 'eori'},
            {label: 'Certificate Of Origin', value: 'certificate_of_origin'},
            {label: 'Dangerous Goods', value: 'dangerous_goods'}
        ];
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
        const StyledSelect = styled(Select)`
            .Select-control {
                background-color: #F9F9F9;
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2 !important;
            }
            .Select-menu-outer {
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2;
            }
            .Select-value {
                background-color: #F9F9F9;
                border: 1px solid #F2F2F2;
            }
            .Select-option {
                background-color: #F9F9F9;
            }
        `;
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
            documents.forEach((doc)=> {
                docView.push(<FileTile key={doc.id} doc={doc} theme={theme} deleteFn={this.props.userDispatch.deleteDocument}/>);
            });
        }
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
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
                        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                            { docView }
                        </div>
                        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                            <div className="flex-50 layout-align-start-center layout-row">
                                <StyledSelect
                                    name="file-type"
                                    className={`${styles.select}`}
                                    value={this.state.fileType}
                                    options={docOptions}
                                    onChange={this.setFileType}
                                />
                            </div>
                            <div className="flex-50 layout-align-end-center layout-row">
                                <FileUploader
                                    theme={theme}
                                    url={this.state.upUrl}
                                    type={this.state.fileType.value}
                                    text={this.state.fileType.label}
                                    uploadFn={userDispatch.uploadDocument}
                                />
                            </div>
                        </div>
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
