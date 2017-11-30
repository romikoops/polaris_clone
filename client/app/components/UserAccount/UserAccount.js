import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './UserAccount.scss';

export { UserProfile, UserLocations, UserEmails, UserPassword, UserBilling };

UserProfile.propTypes = {
    user: PropTypes.object
};

UserLocations.propTypes = {
    user: PropTypes.object
};

UserEmails.propTypes = {
    user: PropTypes.object
};

UserPassword.propTypes = {
    user: PropTypes.object
};

UserBilling.propTypes = {
    user: PropTypes.object
};
