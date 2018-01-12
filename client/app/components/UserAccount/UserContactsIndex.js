import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminSearchableClients} from '../Admin/AdminSearchables';
import styles from './UserAccount.scss';
// import FileUploader from '../FileUploader/FileUploader';
export class UserContactsIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, contacts, viewContact } = this.props;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none clip`} style={textStyle}>Clients</p>
                </div>
                {/* <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                    <p className="flex-none">Upload Clients Sheet</p>
                    <FileUploader theme={theme} url={hubUrl} type="xlsx" text="Client .xlsx"/>
                </div>*/}
                <AdminSearchableClients theme={theme} clients={contacts} handleClick={viewContact}/>
            </div>
        );
    }
}
UserContactsIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    clients: PropTypes.array,
    viewClient: PropTypes.func
};
