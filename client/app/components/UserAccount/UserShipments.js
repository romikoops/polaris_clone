import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './UserAccount.scss';

export class UserShipments extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return <h1>UserShipments</h1>;
    }
}

UserShipments.propTypes = {
    user: PropTypes.object
};
