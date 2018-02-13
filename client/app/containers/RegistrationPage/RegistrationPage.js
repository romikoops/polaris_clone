import React from 'react';
import { connect } from 'react-redux';
import { authenticationActions } from '../../actions';
import { RoundButton } from '../../components/RoundButton/RoundButton';
import { Alert } from '../../components/Alert/Alert';
import { LoadingSpinner } from '../../components/LoadingSpinner/LoadingSpinner';
import styles from './RegistrationPage.scss';
import Formsy from 'formsy-react';
import FormsyInput from '../../components/FormsyInput/FormsyInput';

class RegistrationPage extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            focus: {},
            alertVisible: false
        };

        this.handleFocus = this.handleFocus.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
        this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this);
        this.hideAlert = this.hideAlert.bind(this);
    }

    componentWillMount() {
        if (this.props.registrationAttempt && !this.state.alertVisible) {
            this.setState({ alertVisible: true });
        }
    }

    componentWillReceiveProps(nextProps) {
        if (nextProps.registrationAttempt && !this.state.alertVisible) {
            this.setState({ alertVisible: true });
        }
    }

    hideAlert() {
        this.setState({ alertVisible: false });
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
        user.guest = false;

        const { dispatch, req } = this.props;
        if (req) {
            dispatch(authenticationActions.updateUser(this.props.user, user, req));
        } else {
            dispatch(authenticationActions.register(user));
        }
    }

    handleInvalidSubmit() {
        if (!this.state.submitAttempted) this.setState({ submitAttempted: true });
    }

    render() {
        const { registering, theme } = this.props;
        const focusStyles = {
            borderColor: theme && theme.colors ? theme.colors.primary : 'black',
            borderWidth: '1.5px',
            borderRadius: '2px',
            margin: '-1px 0 29px 0'
        };
        const alert = this.state.alertVisible ? (
            <Alert
                message={{ type: 'error', text: 'Email has already been taken' }}
                onClose={this.hideAlert}
                timeout={10000}
            />
        ) : '';
        return (
            <Formsy
                className={styles.registration_form}
                name="form"
                onValidSubmit={this.handleSubmit}
                onInvalidSubmit={this.handleInvalidSubmit}
            >
                { alert }
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
                            minLength: 'Must be at least two characters long'
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
                            minLength: 'Must be at least two characters long'
                        }}
                        required
                    />
                    <hr style={this.state.focus.last_name ? focusStyles : {}}/>
                </div>
                <div className="form-group">
                    <label htmlFor="email">Email</label>
                    <FormsyInput
                        type="text"
                        className={styles.form_control}
                        onFocus={this.handleFocus}
                        onBlur={this.handleFocus}
                        name="email"
                        submitAttempted={this.state.submitAttempted}
                        validations={{
                            minLength: 2,
                            matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
                        }}
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long',
                            matchRegexp: 'Invalid email'
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
                    <div className={styles.spinner}>
                        { registering && <LoadingSpinner /> }
                    </div>
                </div>
            </Formsy>
        );
    }
}

function mapStateToProps(state) {
    const { registering, registrationAttempt } = state.authentication;
    return {
        registering,
        registrationAttempt
    };
}

const connectedRegistrationPage = connect(mapStateToProps)(RegistrationPage);
export { connectedRegistrationPage as RegistrationPage };
