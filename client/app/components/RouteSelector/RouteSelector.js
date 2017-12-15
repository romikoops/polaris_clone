import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { RouteOption } from '../RouteOption/RouteOption';
import styles from './RouteSelector.scss';
import {v4} from 'node-uuid';
import defs from '../../styles/default_classes.scss';
export class RouteSelector extends Component {
    constructor(props) {
        super(props);
        this.state = {
            routes: this.props.routes
        };
        this.selectRoute = this.selectRoute.bind(this);
        this.togglePublic = this.togglePublic.bind(this);
        this.handleSearchChange = this.handleSearchChange.bind(this);
    }
    selectRoute(route) {
        this.props.setRoute(route);
    }
    togglePublic() {
        this.setState({ viewPublic: !this.state.viewPublic });
    }
    handleSearchChange(event) {
        console.log('changed');
        console.log(this.state.routes);
        const filteredRoutes = this.props.routes.filter(route => (
            route.name.toLowerCase().indexOf(event.target.value.toLowerCase()) > -1
        ));
        console.log(filteredRoutes);
        this.setState({
            routes: filteredRoutes
        });
    }

    render() {
        const { theme } = this.props;
        const { routes } = this.state;
        if (!routes) {
            console.log('(!) No Routes Found (!)');
            return(
                <div className={`flex-100 layout-row layout-align-center-start ${styles.selector}`}>
                    No Routes Found
                </div>
            );
        }
        const routesOptions = routes.map(route => (
            <RouteOption
                key={v4()}
                theme={theme}
                route={route}
                selectOption={this.selectRoute}
            />
        ));
        return(
            <div className={`flex-100 layout-row layout-align-center-start ${styles.selector}`}>
                <div className={`${defs.content_width} layout-row layout-wrap`}>
                    <div className="flex-100 layout-row layout-wrap">
                        <div className="flex-100 layout-row layout-align-space-between-center">
                            <div className="flex-none ayput-row layout-align-start-center">
                                <h4 className="flex-none"> Available Routes</h4>
                            </div>
                            <div className="flex-none ayput-row layout-align-start-center">
                                <input
                                    type="text"
                                    name="search"
                                    onChange={this.handleSearchChange}
                                />
                            </div>
                        </div>
                        <div className="flex-100 layout-row layout-wrap">
                            {routesOptions}
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}
RouteSelector.propTypes = {
    theme: PropTypes.object,
    privateRoutes: PropTypes.array,
    publicRoutes: PropTypes.array,
    setRoute: PropTypes.func
};
