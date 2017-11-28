import React, {Component} from 'react';
import {LandingTop} from '../../components/LandingTop/LandingTop';
import {LandingTopAuthed} from '../../components/LandingTopAuthed/LandingTopAuthed';
// import {Button} from '../../components/Button/Button';
import {ActiveRoutes} from '../../components/ActiveRoutes/ActiveRoutes';
import {BlogPostHighlights} from '../../components/BlogPostHighlights/BlogPostHighlights';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
// { loggedIn ? <LandingTopAuthed className="flex-100" theme={this.props.theme} /> : <LandingTop className="flex-100" theme={this.props.theme} /> }
import './Landing.scss';
import { RoundButton } from '../../components/RoundButton/RoundButton';
class Landing extends Component {
    constructor(props) {
        super(props);
        this.tenant = this.props.tenant;
        console.log(this.props);
    }

    render() {
        const loggedIn = this.props.loggedIn ? this.props.loggedIn : false;
        const theme = this.props.theme;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const primaryColor = {
          color: theme && theme.colors ? theme.colors.primary : 'black'
        };
        const logo = theme ? theme.logo  : '';
        return (
        <div className="wrapper_landing layout-row flex-100 layout-wrap" >
          { loggedIn ? <LandingTopAuthed className="flex-100" theme={theme} /> : <LandingTop className="flex-100" theme={theme} /> }
          <div className="service_box layout-row flex-100 layout-wrap">
            <div className="service_label layout-row layout-align-center-center flex-100">
              <h2 className="flex-none"> Introducing Online LCL Services  {this.props.loggedIn}
              </h2>
            </div>
            <div className="services_row flex-100 layout-row layout-align-center">
              <div className="layout-row flex-100 flex-gt-sm-80 card layout-align-space-between-center">
                <div className="flex-none layout-column layout-align-center-center service">
                  <i className="fa fa-bolt" aria-hidden="true" style={textStyle}></i>
                  <h3> Instant Booking </h3>
                </div>
                <div className="flex-none layout-column layout-align-center-center service">
                  <i className="fa fa-edit" aria-hidden="true" style={textStyle}></i>
                  <h3> Real time quotes </h3>
                </div>
                <div className="flex-none layout-column layout-align-center-center service">
                  <i className="fa fa-binoculars" aria-hidden="true" style={textStyle}></i>
                  <h3>Transparent </h3>
                </div>
                <div className="flex-none layout-column layout-align-center-center service">
                  <i className="fa fa-clock-o" aria-hidden="true" style={textStyle}></i>
                  <h3>Updates in Real Time </h3>
                </div>
              </div>
            </div>
          </div>
          <ActiveRoutes className="mc" theme={theme} />
          <BlogPostHighlights theme={theme} />
          <div className="btm_promo flex-100 layout-row">
            <div className="flex-50 btm_promo_img">
            </div>
            <div className="flex-50 btm_promo_text layout-row layout-align-start-center">
              <div className="flex-80 layout-column">
                <div className="flex-20 layout-column layout-align-center-start">
                  <h2> Enjoy the most advanced and easy to use booking system on the planet </h2>
                </div>
                <div className="flex-40 layout-column layout-align-center-start">
                  <div className="flex layout-row layout-align-start-center">
                    <i className="fa fa-check"> </i>
                    <p> instant booking </p>
                  </div>
                  <div className="flex layout-row layout-align-start-center">
                    <i className="fa fa-check"> </i>
                    <p> price comparison </p>
                  </div>
                   <div className="flex layout-row layout-align-start-center">
                    <i className="fa fa-check"> </i>
                    <p> fastest routes </p>
                  </div>
                   <div className="flex layout-row layout-align-start-center">
                    <i className="fa fa-check"> </i>
                    <p> real time updates </p>
                  </div>
                </div>
                <div className="btm_promo_btn_wrapper flex-20 layout-column layout-align-start-left">
                  <RoundButton text="sign up" theme={theme} active/>
                </div>
              </div>
            </div>
          </div>
          <div className="contact_bar flex-100 layout-row layout-align-center-center">
            <div className="flex-none content-width layout-row">
              <div className="flex-50 layout-row layout-align-start-center">
                <img src={logo} />
              </div>
              <div className="flex-50 layout-row layout-align-end-end">
                <div className="flex-none layout-row layout-align-center-center contact_elem">
                  <i className="fa fa-envelope" aria-hidden="true" style={primaryColor}></i>
                  [ TBD - support@greencarrier.com ]
                </div>
                <div className="flex-none layout-row layout-align-center-end contact_elem">
                  <i className="fa fa-phone" aria-hidden="true" style={primaryColor}></i>
                  [ TBD - 0172 304 203 1020 ]
                </div>
              </div>
            </div>
          </div>
        </div>
      );
    }
}

Landing.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool
};

function mapStateToProps(state) {
    const { users, authentication } = state;
    const { user, loggedIn } = authentication;
    return {
        user,
        users,
        loggedIn
    };
}

export default connect(mapStateToProps)(Landing);
