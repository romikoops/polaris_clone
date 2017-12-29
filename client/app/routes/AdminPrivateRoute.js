import React from 'react';
import { Route, Redirect } from 'react-router-dom';
const user = localStorage.getItem('user');
const admin = user && user.role_id === 1 ? true : false;
console.log(user);
export const AdminPrivateRoute = ({ component: Component, loggedIn, ...rest }) => (
    <Route {...rest} render={props => (
        user && admin && loggedIn
            ? <Component {...props} />
            : <Redirect to={{ pathname: '/', state: { from: props.location } }} />
    )} />
);
