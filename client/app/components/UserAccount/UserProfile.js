import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './UserAccount.scss';

export class UserProfile extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return <h1>UserProfile</h1>;
    }
}

UserProfile.propTypes = {
    user: PropTypes.object
};
