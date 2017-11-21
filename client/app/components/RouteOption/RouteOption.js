import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './RouteOption.scss';
export class RouteOption extends Component {
    constructor(props) {
        super(props);
        this.choose = this.choose.bind(this);
    }
    choose() {
      this.props.selectOption(this.props.route);
    }

    render() {
        // const { theme } = this.props;
        // const borderColour = theme && theme.colors ? '-webkit-linear-gradient(top, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'floralwhite';
        // const borderStyle = {
        //   borderImage: borderColour
        // };
        // debugger;
        return (
          <div key={this.props.route.id} className="flex-100 layout-row">
          <div className="flex-75 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-align-start-center" onClick={this.choose}>
              {this.props.route.name}
            </div>
          </div>
        </div>
        );
    }
}
RouteOption.PropTypes = {
    theme: PropTypes.object,
    route: PropTypes.object,
    selectOption: PropTypes.func
};
