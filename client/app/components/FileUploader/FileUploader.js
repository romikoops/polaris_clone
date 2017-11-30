import React from 'react';
import fetch from 'isomorphic-fetch';
import PropTypes from 'prop-types';
import { Promise } from 'babel-polyfill';
import { BASE_URL } from '../../constants';
import { authHeader } from '../../helpers';
import styles from './FileUploader.scss';
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
        const {url, type} = this.props;
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
        const {theme, type} = this.props;
        const btnStyle = {
            background:
                theme && theme.colors
                    ? '-webkit-linear-gradient(95.41deg, ' +
                      theme.colors.primary +
                      ' 0%,' +
                      theme.colors.secondary +
                      ' 100%)'
                    : 'black'
        };
        return (
          <form onSubmit={this.onFormSubmit}>
            <div className={styles.upload_btn_wrapper}>
              <button className={styles.btn} style={btnStyle}>Upload</button>
              <input type="file" onChange={this.onChange} name={type} />
            </div>
          </form>
       );
    }
}

FileUploader.PropTypes = {
    url: PropTypes.string,
    text: PropTypes.string,
    type: PropTypes.string,
    theme: PropTypes.object
};


export default FileUploader;
