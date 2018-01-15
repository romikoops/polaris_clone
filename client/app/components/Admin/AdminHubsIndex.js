import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { AdminSearchableHubs } from './AdminSearchables';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminHubsIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, hubs, viewHub, adminDispatch} = this.props;
        const hubUrl = '/admin/hubs/process_csv';
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>Hubs</p>
                </div>
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                    <p className="flex-none">Upload Hubs Sheet</p>
                   <FileUploader theme={theme} url={hubUrl} type="xlsx" text="Hub .xlsx"/>
                </div>
                <AdminSearchableHubs theme={theme} hubs={hubs} adminDispatch={adminDispatch} sideScroll={false} handleClick={viewHub} seeAll={false}/>
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
