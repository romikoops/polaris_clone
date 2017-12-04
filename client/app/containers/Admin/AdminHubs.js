import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminHubTile} from './AdminHubTile';
import adminStyles from './Admin.scss';
import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminHubs extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, hubs} = this.props;
        let hubList;
        if (hubs) {
            hubList = hubs.map((hub) =>
                <AdminHubTile key={v4()} hub={hub} theme={theme} />
            );
        } else {
            hubList = [];
        }
        const hubUrl = '/admin/hubs/process_csv';
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-start-center ${adminStyles.sec_title}`}>
                    <p className="flex-none" style={textStyle}>hubs</p>
                </div>
                <div className={`flex-100 layout-row layout-align-space-between-center ${adminStyles.sec_upload}`}>
                    <p className="flex-none">Upload Hubs Sheet</p>
                   <FileUploader theme={theme} url={hubUrl} type="xlsx" text="Hub .xlsx"/>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    {hubList}
                </div>
            </div>
        );
    }
}
AdminHubs.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array
};
