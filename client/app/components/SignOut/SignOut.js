import React, { Component } from 'react';
import { Redirect } from 'react-router';
import { authenticationActions } from '../../actions';
import { connect } from 'react-redux';
import { PropTypes } from 'prop-types';

class SignOut extends Component {
    componentDidMount() {
        const { dispatch } = this.props;
        dispatch(authenticationActions.logout());
    }

    render() {
        return <Redirect to="/" />;
    }
}

function mapStateToProps(state) {
    const { loggingIn } = state.authentication;
    return {
        loggingIn
    };
}

SignOut.propTypes = {
    dispatch: PropTypes.func,
    loggingIn: PropTypes.any,
    theme: PropTypes.object
};

const connectedSignOut = connect(mapStateToProps)(SignOut);
export { connectedSignOut as SignOut };
