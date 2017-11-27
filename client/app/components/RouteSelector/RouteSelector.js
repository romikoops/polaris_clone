import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { RouteOption } from '../RouteOption/RouteOption';
import styles from './RouteSelector.scss';
import { Checkbox } from '../CheckBox/CheckBox';
import {v4} from 'node-uuid';
export class RouteSelector extends Component {
    constructor(props) {
        super(props);
        this.state = {
            viewPublic: false
        };
        this.selectRoute = this.selectRoute.bind(this);
        this.togglePublic = this.togglePublic.bind(this);
    }
    selectRoute(route) {
        this.props.setRoute(route);
    }
    togglePublic() {
        this.setState({viewPublic: !this.state.viewPublic});
    }

    render() {
        const { theme, publicRoutes, privateRoutes } = this.props;
        const pubRoutes = [];
        if (publicRoutes) {
            publicRoutes.forEach(route => {
                pubRoutes.push(<RouteOption key={v4()} theme={theme} route={route} selectOption={this.selectRoute} />);
            });
        }
        const privRoutes = [];
        if (privateRoutes) {
            privateRoutes.forEach(route => {
                privRoutes.push(<RouteOption key={v4()} theme={theme} route={route} selectOption={this.selectRoute} isPrivate/>);
            });
        }
        let routesArr;
        if (this.state.viewPublic) {
            routesArr = [...privRoutes, ...pubRoutes];
        } else {
            routesArr = privRoutes;
        }

        return (
        <div className={`flex-100 layout-row layout-align-center-start ${styles.selector}`}>
            <div className="content-width layout-row layout-wrap">
              <div className="flex-100 layout-row layout-wrap">
                <div className="flex-100 layout-row layout-align-space-between-center">
                    <div className="flex-none ayput-row layout-align-start-center">
                        <h4 className="flex-none"> Available Routes</h4>
                    </div>
                    <div className="flex-none layout-row layout-align-end-center">
                        <h4 className="flex-none"> Show Public Routes</h4>
                        <Checkbox onChange={this.togglePublic} checked={this.state.viewPublic} />
                    </div>
                </div>
                <div className="flex-100 layout-row layout-wrap">
                  {routesArr}
                </div>
              </div>
            </div>
        </div>
        );
    }
}
RouteSelector.PropTypes = {
    theme: PropTypes.object,
    privateRoutes: PropTypes.array,
    publicRoutes: PropTypes.array,
    setRoute: PropTypes.func
};

