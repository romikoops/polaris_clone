import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './UserAccount.scss';

export class UserBilling extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return <h1>UserBilling</h1>;
    }
}

UserBilling.propTypes = {
    user: PropTypes.object
};
