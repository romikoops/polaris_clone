import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Header from '../../components/Header/Header';
import { connect } from 'react-redux';
import { Route } from 'react-router';
import { withRouter } from 'react-router-dom';

class Admin extends Component {
  constructor(props) {
    super(props);
  }
  render(){
    return (
      )
  }
}
Admin.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};

Admin.defaultProps = {
};

function mapStateToProps(state) {
    const { users, authentication, tenant } = state;
    const { user, loggedIn } = authentication;
    return {
        user,
        users,
        tenant,
        loggedIn
    };
}

export default withRouter(connect(mapStateToProps)(Admin));
