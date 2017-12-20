import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './UserAccount.scss';

export class UserPassword extends Component {
    constructor(props) {
        super(props);
    }
    componentDidMount() {
        this.props.setNav('password');
    }

    render() {
        return <h1>UserPassword</h1>;
    }
}

UserPassword.propTypes = {
    user: PropTypes.object
};
