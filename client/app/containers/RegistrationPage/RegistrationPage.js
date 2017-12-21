import React from 'react';
import { connect } from 'react-redux';
import { authenticationActions } from '../../actions';
import { RoundButton } from '../../components/RoundButton/RoundButton';
import styles from './RegistrationPage.scss';

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
            submitted: false
        };

        this.handleChange = this.handleChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
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

    handleSubmit(event) {
        event.preventDefault();
        this.setState({ submitted: true });

        const { user } = this.state;
        if (!(user.first_name && user.last_name && user.email && user.password)) {
            return;
        }
        user.tenant_id = this.props.tenant.data.id;

        const { dispatch, req } = this.props;
        if (req) {
            dispatch(authenticationActions.updateUser(this.props.user.data, user, req));
        } else {
            dispatch(authenticationActions.register(user));
        }
    }

    render() {
        const { registering, theme } = this.props;
        const { user, submitted } = this.state;
        return (
            <form className={styles.registration_form} name="form" onSubmit={this.handleSubmit}>
                <div className={'form-group' + (submitted && !user.first_name ? ' has-error' : '')}>
                    <label htmlFor="first_name">First Name</label>
                    <input type="text" className={styles.form_control} name="first_name" value={user.first_name} onChange={this.handleChange} />
                    {submitted && !user.first_name &&
                        <div className="help-block">First Name is required</div>
                    }
                    <hr/>
                </div>
                <div className={'form-group' + (submitted && !user.last_name ? ' has-error' : '')}>
                    <label htmlFor="last_name">Last Name</label>
                    <input type="text" className={styles.form_control} name="last_name" value={user.last_name} onChange={this.handleChange} />
                    {submitted && !user.last_name &&
                        <div className="help-block">Last Name is required</div>
                    }
                    <hr/>
                </div>
                <div className={'form-group' + (submitted && !user.email ? ' has-error' : '')}>
                    <label htmlFor="email">Username</label>
                    <input type="text" className={styles.form_control} name="email" value={user.email} onChange={this.handleChange} />
                    {submitted && !user.email &&
                        <div className="help-block">Username is required</div>
                    }
                    <hr/>
                </div>
                <div className={'form-group' + (submitted && !user.password ? ' has-error' : '')}>
                    <label htmlFor="password">Password</label>
                    <input type="password" className={styles.form_control} name="password" value={user.password} onChange={this.handleChange} />
                    {submitted && !user.password &&
                        <div className="help-block">Password is required</div>
                    }
                    <hr/>
                </div>
                <div className={`form-group ${styles.form_group_submit_btn}`}>
                    <RoundButton text="register" theme={theme} active/>

                    {registering &&
                        <img src="data:image/gif;base64,R0lGODlhEAAQAPIAAP///wAAAMLCwkJCQgAAAGJiYoKCgpKSkiH/C05FVFNDQVBFMi4wAwEAAAAh/hpDcmVhdGVkIHdpdGggYWpheGxvYWQuaW5mbwAh+QQJCgAAACwAAAAAEAAQAAADMwi63P4wyklrE2MIOggZnAdOmGYJRbExwroUmcG2LmDEwnHQLVsYOd2mBzkYDAdKa+dIAAAh+QQJCgAAACwAAAAAEAAQAAADNAi63P5OjCEgG4QMu7DmikRxQlFUYDEZIGBMRVsaqHwctXXf7WEYB4Ag1xjihkMZsiUkKhIAIfkECQoAAAAsAAAAABAAEAAAAzYIujIjK8pByJDMlFYvBoVjHA70GU7xSUJhmKtwHPAKzLO9HMaoKwJZ7Rf8AYPDDzKpZBqfvwQAIfkECQoAAAAsAAAAABAAEAAAAzMIumIlK8oyhpHsnFZfhYumCYUhDAQxRIdhHBGqRoKw0R8DYlJd8z0fMDgsGo/IpHI5TAAAIfkECQoAAAAsAAAAABAAEAAAAzIIunInK0rnZBTwGPNMgQwmdsNgXGJUlIWEuR5oWUIpz8pAEAMe6TwfwyYsGo/IpFKSAAAh+QQJCgAAACwAAAAAEAAQAAADMwi6IMKQORfjdOe82p4wGccc4CEuQradylesojEMBgsUc2G7sDX3lQGBMLAJibufbSlKAAAh+QQJCgAAACwAAAAAEAAQAAADMgi63P7wCRHZnFVdmgHu2nFwlWCI3WGc3TSWhUFGxTAUkGCbtgENBMJAEJsxgMLWzpEAACH5BAkKAAAALAAAAAAQABAAAAMyCLrc/jDKSatlQtScKdceCAjDII7HcQ4EMTCpyrCuUBjCYRgHVtqlAiB1YhiCnlsRkAAAOwAAAAAAAAAAAA==" />
                    }
                </div>
            </form>
        );
    }
}

function mapStateToProps(state) {
    const { registering } = state.registration;
    return {
        registering
    };
}

const connectedRegistrationPage = connect(mapStateToProps)(RegistrationPage);
export { connectedRegistrationPage as RegistrationPage };
