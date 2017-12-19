import React from 'react';
import fetch from 'isomorphic-fetch';
import PropTypes from 'prop-types';
import { Promise } from 'es6-promise-promise';
import { BASE_URL } from '../../constants';
import { authHeader } from '../../helpers';
import styles from './FileUploader.scss';
import { RoundButton } from '../RoundButton/RoundButton';

class FileUploader extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            file: null
        };
        this.onFormSubmit = this.onFormSubmit.bind(this);
        this.onChange = this.onChange.bind(this);
        this.fileUpload = this.fileUpload.bind(this);
    }
    handleResponse(response) {
        if (!response.ok) {
            return Promise.reject(response.statusText);
        }

        return response.json();
    }
    onFormSubmit(e) {
        e.preventDefault(); // Stop form submit
        this.fileUpload(this.state.file).then((response)=>{
            console.log(response.data);
        });
    }
    onChange(e) {
        // this.setState({file: e.target.files[0]});
        this.fileUpload(e.target.files[0]);
    }
    fileUpload(file) {
        const {url, type, dispatchFn} = this.props;
        if (!file) {
            return '';
        }
        if (dispatchFn) {
            return dispatchFn(file);
        }
        const formData = new FormData();
        formData.append('file', file);
        formData.append('type', type);
        const requestOptions = {
            method: 'POST',
            headers: { ...authHeader()},
            body: formData
        };
        const uploadUrl = BASE_URL + url;
        return fetch(uploadUrl, requestOptions).then(this.handleResponse);
    }

    render() {
        const clickUploaderInput = () => {
            this.uploaderInput.click();
        };
        const {theme, type} = this.props;
        return (
            <div className={styles.upload_btn_wrapper}>
                <form onSubmit={this.onFormSubmit}>
                    <RoundButton text="Upload" theme={theme} size="small" handleNext={clickUploaderInput} active />
                    <input type="file" onChange={this.onChange} name={type} ref={input => { this.uploaderInput = input; }}/>
                </form>
            </div>
        );
    }
}

FileUploader.propTypes = {
    url: PropTypes.string,
    text: PropTypes.string,
    type: PropTypes.string,
    theme: PropTypes.object,
    dispatchFn: PropTypes.func
};


export default FileUploader;
