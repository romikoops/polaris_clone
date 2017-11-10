import React from 'react';
import PropTypes from 'prop-types';
import { renderMergedProps } from './renderMergedProps';
import { Route } from 'react-router-dom';

const PropsRoute = ({ component, ...rest }) => {
    return (
        <Route {...rest} render={routeProps => renderMergedProps(component, routeProps, rest)}/>
    );
};

PropsRoute.propTypes = {
    component: PropTypes.any
};

export default PropsRoute;
