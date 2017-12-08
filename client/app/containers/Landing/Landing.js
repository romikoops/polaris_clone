import React, {Component} from 'react';
import {LandingTop} from '../../components/LandingTop/LandingTop';
import {LandingTopAuthed} from '../../components/LandingTopAuthed/LandingTopAuthed';
import {ActiveRoutes} from '../../components/ActiveRoutes/ActiveRoutes';
import {BlogPostHighlights} from '../../components/BlogPostHighlights/BlogPostHighlights';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import styles from './Landing.scss';
// import defaults from '../../styles/default_classes.scss';
import { RoundButton } from '../../components/RoundButton/RoundButton';
import { withRouter } from 'react-router-dom';

class Landing extends Component {
    constructor(props) {
        super(props);
        this.tenant = this.props.tenant;
        console.log(this.props);
    }

    render() {
        const {loggedIn, theme, user} = this.props;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return (
            <div className={styles.wrapper_landing + ' layout-row flex-100 layout-wrap'} >
                { loggedIn ? <LandingTopAuthed className="flex-100" user={user} theme={theme} /> : <LandingTop className="flex-100" theme={theme} /> }
                <div className={styles.service_box + ' layout-row flex-100 layout-wrap'}>
                    <div className={styles.service_label + ' layout-row layout-align-center-center flex-100'}>
                        <h2 className="flex-none"> Introducing Online LCL Services  {this.props.loggedIn}
                        </h2>
                    </div>
                    <div className={styles.services_row + ' flex-100 layout-row layout-align-center'}>
                        <div className="layout-row flex-100 flex-gt-sm-80 card layout-align-space-between-center">
                            <div className={'flex-none layout-column layout-align-center-center ' + styles.service}>
                                <i className="fa fa-bolt" aria-hidden="true" style={textStyle}></i>
                                <h3> Instant Booking </h3>
                            </div>
                            <div className={'flex-none layout-column layout-align-center-center ' + styles.service}>
                                <i className="fa fa-edit" aria-hidden="true" style={textStyle}></i>
                                <h3> Real time quotes </h3>
                            </div>
                            <div className={'flex-none layout-column layout-align-center-center ' + styles.service}>
                                <i className="fa fa-binoculars" aria-hidden="true" style={textStyle}></i>
                                <h3>Transparent </h3>
                            </div>
                            <div className={'flex-none layout-column layout-align-center-center ' + styles.service}>
                                <i className="fa fa-clock-o" aria-hidden="true" style={textStyle}></i>
                                <h3>Updates in Real Time </h3>
                            </div>
                        </div>
                    </div>
                </div>
                <ActiveRoutes className={styles.mc} theme={theme} />
                <BlogPostHighlights theme={theme} />
                <div className={styles.btm_promo + ' flex-100 layout-row'}>
                    <div className={'flex-50 ' + styles.btm_promo_img}>
                    </div>
                    <div className={styles.btm_promo_text + ' flex-50 layout-row layout-align-start-center'}>
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
                            <div className={styles.btm_promo_btn_wrapper + ' flex-20 layout-column layout-align-start-left'}>
                                <RoundButton text="sign up" theme={theme} active/>
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

export default withRouter(connect(mapStateToProps)(Landing));
