import React, {Component} from 'react';
import PropTypes from 'prop-types';

export class BestRoutesBox extends Component {
    constructor(props) {
        super(props);
    }


    render() {
        const {theme} = this.props;
        const activeBtnStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(top, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'floralwhite',
            color: theme && theme.colors ? 'floralwhite' : 'black'
        };
        return (
        <div className="flex-100 layout-row layout-align-space-between-center">
          <div className="flex-30 layout-row layout-wrap" style={activeBtnStyle}>
            <div className="flex-100 layout-row">
              <h4 className="flex-none">Best Deal</h4>
            </div>
            <div className="flex-100 layout-row">
              <p className="flex-none">500 EUR</p>
            </div>
          </div>
          <div className="flex-30 layout-row layout-wrap">
            <div className="flex-100 layout-row">
              <h4 className="flex-none">Cheapest Route</h4>
            </div>
            <div className="flex-100 layout-row">
              <p className="flex-none">500 EUR</p>
            </div>
          </div>
          <div className="flex-30 layout-row layout-wrap">
            <div className="flex-100 layout-row">
              <h4 className="flex-none">Fastest route</h4>
            </div>
            <div className="flex-100 layout-row">
              <p className="flex-none">500 EUR</p>
            </div>
          </div>
        </div>
        );
    }
}
BestRoutesBox.PropTypes = {
    theme: PropTypes.object
};
