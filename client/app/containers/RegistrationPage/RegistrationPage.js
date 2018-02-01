import React from 'react';
import { connect } from 'react-redux';
import { authenticationActions } from '../../actions';
import { RoundButton } from '../../components/RoundButton/RoundButton';
import styles from './RegistrationPage.scss';
import Formsy from 'formsy-react';
import FormsyInput from '../../components/FormsyInput/FormsyInput';

class RegistrationPage extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            user: {
                first_name: '',
                last_name: '',
                email: '',
                password: '',
                tenant_id: '',
                guest: false
            },
            focus: {}
        };

        this.handleChange = this.handleChange.bind(this);
        this.handleFocus = this.handleFocus.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
        this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this);
    }

    handleChange(event) {
        const { name, value } = event.target;
        const { user } = this.state;
        this.setState({
            user: {
                ...user,
                [name]: value
            }
        });
    }

    handleFocus(e) {
        this.setState({
            focus: {
                ...this.state.focus,
                [e.target.name]: e.type === 'focus'
            }
        });
    }

    handleSubmit(model) {
        const user = Object.assign({}, model);
        user.tenant_id = this.props.tenant.data.id;

        const { dispatch, req } = this.props;
        if (req) {
            dispatch(authenticationActions.updateUser(this.props.user.data, user, req));
        } else {
            dispatch(authenticationActions.register(user));
        }
    }

    handleInvalidSubmit() {
        console.log('invalid');
        if (!this.state.submitAttempted) this.setState({ submitAttempted: true });
    }

    render() {
        const { registering, theme } = this.props;
        const focusStyles = {
            borderColor: theme && theme.colors ? theme.colors.primary : 'black',
            borderWidth: '1.5px',
            borderRadius: '2px',
            margin: '-0.75px 0 29px 0'
        };
        return (
            <Formsy
                className={styles.registration_form}
                name="form"
                onValidSubmit={this.handleSubmit}
                onInvalidSubmit={this.handleInvalidSubmit}
            >
                <div className="form-group">
                    <label htmlFor="first_name">First Name</label>
                    <FormsyInput
                        type="text"
                        className={styles.form_control}
                        onFocus={this.handleFocus}
                        onBlur={this.handleFocus}
                        name="first_name"
                        submitAttempted={this.state.submitAttempted}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must have at least 2 characters'
                        }}
                        required
                    />
                    <hr style={this.state.focus.first_name ? focusStyles : {}}/>
                </div>
                <div className="form-group">
                    <label htmlFor="last_name">Last Name</label>
                    <FormsyInput
                        type="text"
                        className={styles.form_control}
                        onFocus={this.handleFocus}
                        onBlur={this.handleFocus}
                        name="last_name"
                        submitAttempted={this.state.submitAttempted}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must have at least 2 characters'
                        }}
                        required
                    />
                    <hr style={this.state.focus.last_name ? focusStyles : {}}/>
                </div>
                <div className="form-group">
                    <label htmlFor="email">Username</label>
                    <FormsyInput
                        type="text"
                        className={styles.form_control}
                        onFocus={this.handleFocus}
                        onBlur={this.handleFocus}
                        name="email"
                        submitAttempted={this.state.submitAttempted}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must have at least 2 characters'
                        }}
                        required
                    />
                    <hr style={this.state.focus.email ? focusStyles : {}}/>
                </div>
                <div className="form-group">
                    <label htmlFor="password">Password</label>
                    <FormsyInput
                        type="password"
                        className={styles.form_control}
                        onFocus={this.handleFocus}
                        onBlur={this.handleFocus}
                        name="password"
                        submitAttempted={this.state.submitAttempted}
                        validations="minLength:8"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must have at least 8 characters'
                        }}
                        required
                    />
                    <hr style={this.state.focus.password ? focusStyles : {}}/>
                </div>
                <div className="form-group">
                    <label htmlFor="password">Confirm Password</label>
                    <FormsyInput
                        type="password"
                        className={styles.form_control}
                        onFocus={this.handleFocus}
                        onBlur={this.handleFocus}
                        name="confirm_password"
                        submitAttempted={this.state.submitAttempted}
                        validations="equalsField:password"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            equalsField: 'Must match password'
                        }}
                        required
                    />
                    <hr style={this.state.focus.confirm_password ? focusStyles : {}}/>
                </div>
                <div className={`form-group ${styles.form_group_submit_btn}`}>
                    <RoundButton text="register" theme={theme} active/>

                    {registering &&
                        <img src="data:image/gif;base64,R0lGODlhEAAQAPIAAP///wAAAMLCwkJCQgAAAGJiYoKCgpKSkiH/C05FVFNDQVBFMi4wAwEAAAAh/hpDcmVhdGVkIHdpdGggYWpheGxvYWQuaW5mbwAh+QQJCgAAACwAAAAAEAAQAAADMwi63P4wyklrE2MIOggZnAdOmGYJRbExwroUmcG2LmDEwnHQLVsYOd2mBzkYDAdKa+dIAAAh+QQJCgAAACwAAAAAEAAQAAADNAi63P5OjCEgG4QMu7DmikRxQlFUYDEZIGBMRVsaqHwctXXf7WEYB4Ag1xjihkMZsiUkKhIAIfkECQoAAAAsAAAAABAAEAAAAzYIujIjK8pByJDMlFYvBoVjHA70GU7xSUJhmKtwHPAKzLO9HMaoKwJZ7Rf8AYPDDzKpZBqfvwQAIfkECQoAAAAsAAAAABAAEAAAAzMIumIlK8oyhpHsnFZfhYumCYUhDAQxRIdhHBGqRoKw0R8DYlJd8z0fMDgsGo/IpHI5TAAAIfkECQoAAAAsAAAAABAAEAAAAzIIunInK0rnZBTwGPNMgQwmdsNgXGJUlIWEuR5oWUIpz8pAEAMe6TwfwyYsGo/IpFKSAAAh+QQJCgAAACwAAAAAEAAQAAADMwi6IMKQORfjdOe82p4wGccc4CEuQradylesojEMBgsUc2G7sDX3lQGBMLAJibufbSlKAAAh+QQJCgAAACwAAAAAEAAQAAADMgi63P7wCRHZnFVdmgHu2nFwlWCI3WGc3TSWhUFGxTAUkGCbtgENBMJAEJsxgMLWzpEAACH5BAkKAAAALAAAAAAQABAAAAMyCLrc/jDKSatlQtScKdceCAjDII7HcQ4EMTCpyrCuUBjCYRgHVtqlAiB1YhiCnlsRkAAAOwAAAAAAAAAAAA==" />
                    }
                </div>
            </Formsy>
        );
    }
}

function mapStateToProps(state) {
    const { registering } = state.authentication;
    return {
        registering
    };
}

const connectedRegistrationPage = connect(mapStateToProps)(RegistrationPage);
export { connectedRegistrationPage as RegistrationPage };
