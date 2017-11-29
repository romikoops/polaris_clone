import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { CSSTransitionGroup } from 'react-transition-group';
import styles from './loading.scss';
export class Loading extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        const {theme, text} = this.props;
        const logo = theme && theme.logo ? theme.logo : '';
        const backgroundStyle = { backgroundColor: theme && theme.colors ? theme.colors.primary : 'darkslategrey'};

        return (
      <div className={`layout-row layout-align-center-center ${styles.loader_box}`}>
        <CSSTransitionGroup transitionName="loader_anim" transitionAppear transitionEnterTimeout={500} transitionLeaveTimeout={500}>
          <div className={`layout-column layout-align-center-center ${styles.loader}`} style={backgroundStyle}>
            <img src={logo} alt="" className="flex-none"/>
            <p className="flex-none">{text}</p>
          </div>
        </CSSTransitionGroup>
      </div>
      );
    }
}
Loading.PropTypes = {
    theme: PropTypes.object,
    text: PropTypes.string
};
