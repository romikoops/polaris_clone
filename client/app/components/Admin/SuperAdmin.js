import React, { Component } from 'react';
import PropTypes from 'prop-types';
import FileUploader from '../../components/FileUploader/FileUploader';
export class SuperAdmin extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme} = this.props;
        const upUrl = '/super_admins/new_demo';
        return(
            <div className="flex-100 layout-row layout-align-space-between-center" >
                <p className="flex-none">Upload Demo Tenant Object</p>
                <FileUploader theme={theme} url={upUrl} type="xlsx" text="Tenant"/>
            </div>
        );
    }
}
SuperAdmin.propTypes = {
    theme: PropTypes.object,
    navLink: PropTypes.func
};
