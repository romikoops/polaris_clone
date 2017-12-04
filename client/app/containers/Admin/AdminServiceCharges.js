import React, { Component } from 'react';
import PropTypes from 'prop-types';
import adminStyles from './Admin.scss';
import { AdminChargePanel } from './AdminChargePanel';
import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminServiceCharges extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, hubs, charges } = this.props;
        let chargeList;
        if (charges) {
            chargeList = charges.map((charge) =>
                <AdminChargePanel key={v4()} hub={hubs[0]} theme={theme} charge={charge}/>
            );
        } else {
            chargeList = [];
        }
        const scUrl = '/admin/service_charges/process_csv';
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-start-center ${adminStyles.sec_title}`}>
                    <p className="flex-none" style={textStyle}>service charges</p>
                </div>
                <div className={`flex-100 layout-row layout-align-space-between-center ${adminStyles.sec_upload}`}>
                    <p className="flex-none">Upload Service Charges Sheet</p>
                   <FileUploader theme={theme} url={scUrl} type="xlsx" text="Service Charges .xlsx"/>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    {chargeList}
                </div>
            </div>
        );
    }
}
AdminServiceCharges.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    charges: PropTypes.array
};
