import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { Redirect } from 'react-router';
// import { Link } from 'react'
import styles from './CardLink.scss';
// import { connect } from 'react-redux';
import { tenantDefaults } from '../../constants';
export class CardLink extends Component {
    constructor(props) {
        super(props);
        this.state = {
            redirect: false
        };
    }

    // handleOnClick = () => {
    //   this.context.router.push(this.props.path);
    // }
    render() {
        if (this.state.redirect) {
            return <Redirect push to={this.props.path} />;
        }
        const theme = this.props.theme ? this.props.theme : tenantDefaults.theme;
        const display = this.props.text;
        const handleClick = () => this.setState({ redirect: true });
        const imgClass = { backgroundImage: 'url(' + this.props.img + ')'};
        const textColour = { color: theme.colors.primary };
        return (
          <div className={`${styles.card_link}  layout-column flex-100 flex-gt-sm-30`} onClick={handleClick} >
            <div className={`${styles.card_img}  flex-85`} style={imgClass}>
            </div>
            <div className={`${styles.card_action}  flex-15 layout-row layout-align-space-between-center`}>
              <div className="flex-none layout-row layout-align-center-center" >
                <p className="flex-none">{display} </p>
              </div>
              <div className="flex-none layout-row layout-align-center-center">
                <i className="flex-none fa fa-chevron-right" style={textColour} ></i>
              </div>
            </div>
          </div>
        );
    }
}

CardLink.propTypes = {
    text: PropTypes.string,
    img: PropTypes.string,
    theme: PropTypes.object,
    path: PropTypes.string
};
