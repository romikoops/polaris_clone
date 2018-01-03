import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminSearchableClients} from './AdminSearchables';
import styles from './Admin.scss';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminClientsIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, clients, adminDispatch } = this.props;
        const hubUrl = '/admin/clients/process_csv';
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>Clients</p>
                </div>
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                    <p className="flex-none">Upload Clients Sheet</p>
                    <FileUploader theme={theme} url={hubUrl} type="xlsx" text="Client .xlsx"/>
                </div>
                <AdminSearchableClients theme={theme} clients={clients} adminDispatch={adminDispatch}/>
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
