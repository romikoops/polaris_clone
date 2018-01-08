import React from 'react';
import fetch from 'isomorphic-fetch';
import PropTypes from 'prop-types';
import { Promise } from 'es6-promise-promise';
import { BASE_URL } from '../../constants';
import { authHeader } from '../../helpers';
import styles from './FileTile.scss';
// import { RoundButton } from '../RoundButton/RoundButton';
import { moment, documentTypes } from '../../constants';
import {Link} from 'react-router-dom';
const docTypes = documentTypes;
class FileTile extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            file: null
        };
        this.onFormSubmit = this.onFormSubmit.bind(this);
        this.onChange = this.onChange.bind(this);
        this.fileUpload = this.fileUpload.bind(this);
        this.deleteFile = this.deleteFile.bind(this);
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
    // Delete the file
    deleteFile() {
        const {doc, deleteFn} = this.props;
        deleteFn(doc.id);
    }
    fileUpload(file) {
        const {type, dispatchFn, doc} = this.props;
        const url = '/shipments/' + doc.shipment_id + '/upload/' + doc.doc_type;
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
        const {theme, type, doc} = this.props;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const link = doc.signed_url ?
            (<Link to={doc.signed_url} className="flex-none layout-row layout-align-center-center" target="_blank">
                <i className="clip fa fa-eye" style={textStyle}></i>
            </Link>) :
            '';
        return (
            <div className={`flex-none layout-row layout-wrap layout-align-center-start ${styles.tile}`}>
                <div className="flex-100 layout-row layout-wrap layout-align-center-center">
                    <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                        <div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.file_header}`}>
                            <p className="flex-100">Title</p>
                        </div>
                        <div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.file_text}`}>
                            <p className="flex-100">{doc.text}</p>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                        <div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.file_header}`}>
                            <p className="flex-100">Type</p>
                        </div>
                        <div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.file_text}`}>
                            <p className="flex-100">{docTypes[doc.doc_type]}</p>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                        <div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.file_header}`}>
                            <p className="flex-100">Uploaded</p>
                        </div>
                        <div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.file_text}`}>
                            <p className="flex-100">{moment(doc.created_at).format('lll')}</p>
                        </div>
                    </div>
                </div>
                <div className="flex-100 layout-row layout-align-center-end">
                    <div className={`${styles.upload_btn_wrapper} flex-33 layout-row layout-align-center-center`}>
                        <form className="flex-none layout-row layout-align-center-center" onSubmit={this.onFormSubmit}>
                            <div className="flex-none" onClick={clickUploaderInput}>
                                <i className="fa fa-pencil clip" style={textStyle}></i>
                            </div>
                            <input type="file" onChange={this.onChange} name={type} ref={input => { this.uploaderInput = input; }}/>
                        </form>
                    </div>
                    <div className={`${styles.upload_btn_wrapper} flex-33 layout-row layout-align-center-center`}>
                        <div className="flex-none layout-row layout-align-center-center" onClick={this.deleteFile} >
                            <i className="clip fa fa-trash" style={textStyle}></i>
                        </div>
                    </div>
                    <div className={`${styles.upload_btn_wrapper} flex-33 layout-row layout-align-center-center`}>
                        {link}
                    </div>
                </div>

            </div>
        );
    }
}

FileTile.propTypes = {
    url: PropTypes.string,
    text: PropTypes.string,
    type: PropTypes.string,
    theme: PropTypes.object,
    dispatchFn: PropTypes.func
};


export default FileTile;
