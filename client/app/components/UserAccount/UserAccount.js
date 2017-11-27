import React, { Component } from 'react';
import PropTypes from 'prop-types';
import './UserAccount.scss';

class UserProfile extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return <h1>UserProfile</h1>;
  }
}

class UserLocations extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return <h1>UserLocations</h1>;
  }
}
class UserEmails extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return <h1>UserEmails</h1>;
  }
}
class UserPassword extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return <h1>UserPassword</h1>;
  }
}
class UserBilling extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return <h1>UserBilling</h1>;
  }
}

export {
  UserProfile,
  UserLocations,
  UserEmails,
  UserPassword,
  UserBilling
};

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
