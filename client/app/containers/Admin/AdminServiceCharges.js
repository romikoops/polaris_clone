import React, { Component } from 'react';
import PropTypes from 'prop-types';
import adminStyles from './Admin.scss';
import {AdminHubTile} from './AdminHubTile';
import { AdminChargePanel } from './AdminChargePanel';
import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminServiceCharges extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedHub: false
        };
        this.selectHub = this.selectHub.bind(this);
        this.deselectHub = this.deselectHub.bind(this);
    }
    selectHub(hub) {
        this.setState({selectedHub: hub});
    }
    deselectHub() {
        this.setState({selectedHub: false});
    }
    render() {
        const {theme, hubs, charges } = this.props;
        const {selectedHub} = this.state;
        let hubList;
        if (hubs) {
            hubList = hubs.map((hub) =>
                <AdminHubTile key={v4()} hub={hub} theme={theme} handleClick={this.selectHub}/>
            );
        } else {
            hubList = [];
        }
        let chargeList = '';
        if (charges && selectedHub) {
            charges.forEach((charge) =>{
                if (charge.hub_id === selectedHub.data.id) {
                    chargeList = <AdminChargePanel key={v4()} hub={selectedHub} theme={theme} charge={charge} backFn={this.deselectHub}/>;
                }
            });
        }
        console.log(chargeList);
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
                    {selectedHub ? chargeList : hubList}
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
