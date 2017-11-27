import React, {Component} from 'react';
import PropTypes from 'prop-types';

import styles from './RouteHubBox.scss';
export class RouteHubBox extends Component {
    constructor(props) {
        super(props);
    }
    faIcon(sched) {
        const faKeywords = {
            'ocean': 'ship',
            'air': 'plane',
            'train': 'train'
        };
        const faClass = `fa fa-${faKeywords[sched.mode_of_transport]}`;
        return <i className={faClass}/>;
    }
    dashedGradient(color1, color2) {
        return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`;
    }
    render() {
        const { theme, hubs, route } = this.props;
        const { startHub, endHub } = hubs;
        const gradientStyle = {
            background: theme && theme.colors ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${theme.colors.secondary})` : 'black'
        };
        const dashedLineStyles = {
            marginTop: '6px',
            height: '2px',
            width: '100%',
            background: theme && theme.colors ? this.dashedGradient(theme.colors.primary, theme.colors.secondary) : 'black',
            backgroundSize: '16px 2px, 100% 2px'
        };
        return (
        <div className="flex-100 layout-row layout-align-center-center">
          <div className="flex-none content-width layout-row layout-align-start-center">
            <div className={`flex-none ${styles.hub_card} layout-row`}>
              <div className="flex-15 layout-column layout-align-start-center">
                <i className="fa fa-map-marker" style={gradientStyle}/>
              </div>
              <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                <h6 className="flex-100"> {startHub.data.name} </h6>
                <p className="flex-100">{ startHub.location.geocoded_address }</p>
              </div>
            </div>

            <div className={`${styles.connection_graphics} flex-20 layout-row layout-align-center-start`} >
                <div className="flex-100 layout-row layout-align-center-start">
                    <div className="flex-80">
                        <div className="flex-none layout-row layout-align-center-center">
                            {this.faIcon(route[0])}
                        </div>
                        <div style={dashedLineStyles}></div>
                    </div>
                </div>
            </div>

            <div className={`flex-none ${styles.hub_card} layout-row`}>
              <div className="flex-15 layout-column layout-align-start-center">
                <i className="fa fa-flag" style={gradientStyle}/>
              </div>
              <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                <h6 className="flex-100"> {endHub.data.name} </h6>
                <p className="flex-100">{ endHub.location.geocoded_address }</p>
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
