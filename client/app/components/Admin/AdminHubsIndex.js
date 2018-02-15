import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { AdminSearchableHubs } from './AdminSearchables';
import FileUploader from '../../components/FileUploader/FileUploader';
import { adminHubs as hubsTip } from '../../constants';
export class AdminHubsIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, hubs, viewHub, adminDispatch} = this.props;
        const hubUrl = '/admin/hubs/process_csv';
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                    <p className="flex-none">Upload Hubs Sheet</p>
                    <FileUploader
                        theme={theme}
                        url={hubUrl}
                        type="xlsx"
                        text="Hub .xlsx"
                    />
                </div>
                <AdminSearchableHubs
                    theme={theme}
                    hubs={hubs}
                    adminDispatch={adminDispatch}
                    sideScroll={false}
                    handleClick={viewHub}
                    seeAll={false}
                    icon="fa-info-circle"
                    tooltip={hubsTip.manage}
                />
            </div>
        );
    }
}
AdminHubsIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    clients: PropTypes.array,
    viewClient: PropTypes.func
};
