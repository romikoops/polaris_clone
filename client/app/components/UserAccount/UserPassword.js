import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './UserAccount.scss';

class UserPassword extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return <h1>UserPassword</h1>;
    }
}

UserPassword.propTypes = {
    user: PropTypes.object
};