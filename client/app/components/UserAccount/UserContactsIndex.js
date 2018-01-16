import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminSearchableClients} from '../Admin/AdminSearchables';
// import styles from './UserAccount.scss';
// import FileUploader from '../FileUploader/FileUploader';
export class UserContactsIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, contacts, viewContact } = this.props;
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <AdminSearchableClients theme={theme} clients={contacts} title="All Contacts" handleClick={viewContact} seeAll={false}/>
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
