import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminSearchableClients} from './AdminSearchables';
import styles from './Admin.scss';
import FileUploader from '../../components/FileUploader/FileUploader';
import { adminClientsTooltips as clientTip } from '../../constants';
export class AdminClientsIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, clients, adminDispatch } = this.props;
        const hubUrl = '/admin/clients/process_csv';
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                    <p className="flex-none">Upload Clients Sheet</p>
                    <FileUploader
                        theme={theme}
                        url={hubUrl}
                        type="xlsx"
                        text="Client .xlsx"
                        tooltip={clientTip.upload}
                    />
                </div>
                <AdminSearchableClients
                    theme={theme}
                    clients={clients}
                    adminDispatch={adminDispatch}
                    tooltip={clientTip.manage}
                    showTooltip
                />
            </div>
        );
    }
}
AdminClientsIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    clients: PropTypes.array,
    viewClient: PropTypes.func
};
