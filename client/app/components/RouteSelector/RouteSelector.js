import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { RouteOption } from '../RouteOption/RouteOption';

export class RouteSelector extends Component {
    constructor(props) {
        super(props);
        this.selectRoute = this.selectRoute.bind(this);
    }
    selectRoute(route) {
        this.props.setRoute(route);
    }

    render() {
        const pubRoutes = [];
        if (this.props.publicRoutes) {
            this.props.publicRoutes.forEach(route => {
                pubRoutes.push(<RouteOption route={route} selectOption={this.selectRoute}/>);
            });
        }
        const privRoutes = [];
        if (this.props.privateRoutes) {
            this.props.privateRoutes.forEach(route => {
                privRoutes.push(<RouteOption route={route} selectOption={this.selectRoute}/>);
            });
        }
        return (
        <div className="flex-100 layout-row layout-align-center-start">
            <div className="flex-75 layout-row layout-wrap">
              <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap">
                <div className="flex-100 layout-row layout-align-start-center">
                    <h4 className="flex-none"> Available Private Routes</h4>
                </div>
                <div className="flex-100 layout-row layout-wrap">
                  {privRoutes}
                </div>
              </div>
              <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap">
                <div className="flex-100 layout-row layout-align-start-center">
                    <h4 className="flex-none"> Available Public Routes</h4>
                </div>
                <div className="flex-100 layout-row layout-wrap">
                  {pubRoutes}
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

