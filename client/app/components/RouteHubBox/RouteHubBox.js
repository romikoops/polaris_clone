import React, {Component} from 'react';
import PropTypes from 'prop-types';

import './RouteHubBox.scss';
export class RouteHubBox extends Component {
    constructor(props) {
        super(props);
    }
    switchIcon(sched) {
        let icon;
        switch(sched.mode_of_transport) {
            case 'ocean':
                icon = <i className="fa fa-ship"/>;
                break;
            case 'air':
                icon = <i className="fa fa-plane"/>;
                break;
            case 'train':
                icon = <i className="fa fa-train"/>;
                break;
            default:
                icon = <i className="fa fa-ship"/>;
                break;
        }
        return icon;
    }
    render() {
        const { theme, hubs, route } = this.props;
        const {startHub, endHub} = hubs;
        const themeColour = { color: theme.colors ? theme.colors.primary : 'white'};
        const borderColour = theme && theme.colors ? '-webkit-linear-gradient(top, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'floralwhite';
        const borderStyle = {
            borderImage: borderColour
        };
        return (
        <div className="flex-100 layout-row layout-align-center-center">
          <div className="flex-75 layout-row layout-align-start-center">
            <div className="flex-none hub_card layout-row">
              <div className="flex-15 layout-column layout-align-start-center">
                <i className="fa fa-location" style={themeColour}/>
              </div>
              <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                <h6 className="flex-100"> {startHub.name} </h6>
                <p className="flex-100">{ startHub.geocoded_address }</p>
              </div>
            </div>

            <div className="flex-15 layout-row layout-wrap layout-align-center-start" >
                <div className="flex-100 layout-row layout-align-center-center dash_border" style={borderStyle}>
                  { this.switchIcon(route)}
                </div>
            </div>

            <div className="flex-none hub_card layout-row">
              <div className="flex-15 layout-column layout-align-start-center">
                <i className="fa fa-flag" style={themeColour}/>
              </div>
              <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                <h6 className="flex-100"> {endHub.name} </h6>
                <p className="flex-100">{ endHub.geocoded_address }</p>
              </div>
            </div>

          </div>
        </div>
      );
    }
}
RouteHubBox.PropTypes = {
    theme: PropTypes.object,
    route: PropTypes.object,
    hubs: PropTypes.object
};
