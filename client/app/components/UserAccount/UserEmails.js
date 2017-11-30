import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './UserAccount.scss';

class UserEmails extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return <h1>UserEmails</h1>;
    }
}

UserEmails.propTypes = {
    user: PropTypes.object
};
