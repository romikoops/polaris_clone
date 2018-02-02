import React from 'react';
import { connect } from 'react-redux';
import { PropTypes } from 'prop-types';
import { authenticationActions } from '../../actions';
import { RoundButton } from '../../components/RoundButton/RoundButton';
import { Alert } from '../../components/Alert/Alert';
import styles from './LoginPage.scss';
import Formsy from 'formsy-react';
import FormsyInput from '../../components/FormsyInput/FormsyInput';

class LoginPage extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            submitAttempted: false,
            focus: {},
            alertVisible: false
        };

        this.handleSubmit = this.handleSubmit.bind(this);
        this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this);
        this.handleFocus = this.handleFocus.bind(this);
        this.hideAlert = this.hideAlert.bind(this);
    }
    componentWillMount() {
        if (this.props.loginAttempt && !this.state.alertVisible) {
            this.setState({ alertVisible: true });
        }
    }

    componentWillReceiveProps(nextProps) {
        if (nextProps.loginAttempt && !this.state.alertVisible) {
            this.setState({ alertVisible: true });
        }
    }

    hideAlert() {
        this.setState({ alertVisible: false });
    }

    handleSubmit(model) {
        const { username, password } = model;
        const { dispatch, req, noRedirect } = this.props;
        if (username && password) {
            dispatch(authenticationActions.login({
                email: username,
                password: password,
                shipmentReq: req,
                noRedirect
            }));
        }
    }
    handleInvalidSubmit() {
        if (!this.state.submitAttempted) this.setState({ submitAttempted: true });
    }

    handleFocus(e) {
        this.setState({
            focus: {
                ...this.state.focus,
                [e.target.name]: e.type === 'focus'
            }
        });
    }

    render() {
        const { loggingIn, theme } = this.props;
        const focusStyles = {
            borderColor: theme && theme.colors ? theme.colors.primary : 'black',
            borderWidth: '1.5px',
            borderRadius: '2px',
            margin: '-0.75px 0 28.25px 0'
        };
        const alert = this.state.alertVisible ? (
            <Alert
                message={{ type: 'error', text: 'Wrong username or password' }}
                onClose={this.hideAlert}
                timeout={10000}
            />
        ) : '';
        return (
            <Formsy
                className={styles.login_form}
                name="form"
                onValidSubmit={this.handleSubmit}
                onInvalidSubmit={this.handleInvalidSubmit}
            >
                { alert }
                <div className="form-group">
                    <label htmlFor="username">Username</label>
                    <FormsyInput
                        type="text"
                        value={this.props.user ? this.props.user.email : ''}
                        className={styles.form_control}
                        onFocus={this.handleFocus}
                        onBlur={this.handleFocus}
                        name="username"
                        placeholder="enter your username"
                        submitAttempted={this.state.submitAttempted}
                        validationErrors={{isDefaultRequiredValue: 'Must not be blank'}}
                        required
                    />
                    <hr style={this.state.focus.username ? focusStyles : {}}/>
                </div>
                <div className="form-group">
                    <label htmlFor="password">Password</label>
                    <FormsyInput
                        type="password"
                        value={this.props.user ? this.props.user.password : ''}
                        className={styles.form_control}
                        name="password"
                        placeholder="enter your password"
                        submitAttempted={this.state.submitAttempted}
                        validationErrors={{isDefaultRequiredValue: 'Must not be blank'}}
                        required
                    />
                    <hr style={this.state.focus.password ? focusStyles : {}}/>
                    <a href="#" className={styles.forget_password_link}>forgot password?</a>
                </div>
                <div className={`form-group ${styles.form_group_submit_btn}`}>
                    <RoundButton text="Sign In" theme={theme} active/>

                    <div style={{height: '10px'}}>
                        {loggingIn &&
                            <img src="data:image/gif;base64,R0lGODlhEAAQAPIAAP///wAAAMLCwkJCQgAAAGJiYoKCgpKSkiH/C05FVFNDQVBFMi4wAwEAAAAh/hpDcmVhdGVkIHdpdGggYWpheGxvYWQuaW5mbwAh+QQJCgAAACwAAAAAEAAQAAADMwi63P4wyklrE2MIOggZnAdOmGYJRbExwroUmcG2LmDEwnHQLVsYOd2mBzkYDAdKa+dIAAAh+QQJCgAAACwAAAAAEAAQAAADNAi63P5OjCEgG4QMu7DmikRxQlFUYDEZIGBMRVsaqHwctXXf7WEYB4Ag1xjihkMZsiUkKhIAIfkECQoAAAAsAAAAABAAEAAAAzYIujIjK8pByJDMlFYvBoVjHA70GU7xSUJhmKtwHPAKzLO9HMaoKwJZ7Rf8AYPDDzKpZBqfvwQAIfkECQoAAAAsAAAAABAAEAAAAzMIumIlK8oyhpHsnFZfhYumCYUhDAQxRIdhHBGqRoKw0R8DYlJd8z0fMDgsGo/IpHI5TAAAIfkECQoAAAAsAAAAABAAEAAAAzIIunInK0rnZBTwGPNMgQwmdsNgXGJUlIWEuR5oWUIpz8pAEAMe6TwfwyYsGo/IpFKSAAAh+QQJCgAAACwAAAAAEAAQAAADMwi6IMKQORfjdOe82p4wGccc4CEuQradylesojEMBgsUc2G7sDX3lQGBMLAJibufbSlKAAAh+QQJCgAAACwAAAAAEAAQAAADMgi63P7wCRHZnFVdmgHu2nFwlWCI3WGc3TSWhUFGxTAUkGCbtgENBMJAEJsxgMLWzpEAACH5BAkKAAAALAAAAAAQABAAAAMyCLrc/jDKSatlQtScKdceCAjDII7HcQ4EMTCpyrCuUBjCYRgHVtqlAiB1YhiCnlsRkAAAOwAAAAAAAAAAAA==" />
                        }
                    </div>
                </div>
            </Formsy>
        );
    }
}

function mapStateToProps(state) {
    const { loggingIn, loginAttempt, user } = state.authentication;
    return {
        loggingIn,
        loginAttempt,
        user
    };
}

LoginPage.propTypes = {
    dispatch: PropTypes.func,
    loggingIn: PropTypes.any,
    theme: PropTypes.object
};

const connectedLoginPage = connect(mapStateToProps)(LoginPage);
export { connectedLoginPage as LoginPage };
