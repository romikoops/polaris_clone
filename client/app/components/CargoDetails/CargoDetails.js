import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './CargoDetails.scss';
import { Checkbox } from '../Checkbox/Checkbox';
import FileUploader from '../FileUploader/FileUploader';
import { HSCodeRow } from '../HSCodeRow/HSCodeRow';
import defaults from '../../styles/default_classes.scss';
import Truncate from 'react-truncate';
export class CargoDetails extends Component {
    constructor(props) {
        super(props);
        this.state = {
            insuranceView: true,
            customsView: true,
            hsCodes: {},
            cargoNotes: '',
            totalGoodsValue: 0
        };
        this.toggleInsurance = this.toggleInsurance.bind(this);
        this.toggleCustoms = this.toggleCustoms.bind(this);
        this.handleChange = this.handleChange.bind(this);
        this.fileFn = this.fileFn.bind(this);
        this.calcCustomsFee = this.calcCustomsFee.bind(this);
    }
    toggleInsurance() {
        this.setState({ insuranceView: !this.state.insuranceView });
        // this.props.handleInsurance();
    }
    toggleCustoms() {
        this.setState({ customsView: !this.state.customsView });
        // this.timeoutId = setTimeout(function() {
        this.setState({ showNoCustoms: this.state.customsView });
        // }.bind(this), 1000);
    }
    deleteDoc(key) {
        const { shipmentData, shipmentDispatch } = this.props;
        const { documents } = shipmentData;
        const id = documents[key].id;
        shipmentDispatch.deleteDocument(id);
    }
    fileFn(file) {
        const { shipmentData, shipmentDispatch } = this.props;
        const { shipment } = shipmentData;
        const type = file.doc_type;
        const url = '/shipments/' + shipment.id + '/upload/' + type;
        shipmentDispatch.uploadDocument(file, type, url);
    }

    calcCustomsFee() {
        const { hsCodes, shipmentData } = this.props;
        const { customs, cargoItems, containers } = shipmentData;
        let hsCount = 0;
        cargoItems.forEach((ci) => {
            if (hsCodes[ci.id]) {
                hsCount += hsCodes[ci.id].length;
            }
        });
        containers.forEach((cn) => {
            if (hsCodes[cn.id]) {
                hsCount += hsCodes[cn.id].length;
            }
        });
        if (hsCount > customs.limit) {
            const diff = hsCount - customs.limit;
            return customs.fee + (diff * customs.extra);
        }
        return customs.fee;
    }
    handleChange(event) {
        this.props.handleChange(event);
    }
    render() {
        const { shipmentData, theme, insurance, hsCodes, setHsCode, deleteCode } = this.props;
        const { shipment, dangerousGoods, documents, customs, cargoItems, containers } = shipmentData;
        console.log(customs);
        console.log(shipment);
        const DocViewer = ({doc}) => {
            return(
                <div className="flex-100 layout-row layout-align-start-center">
                    <p className={`flex-80 ${styles.doc_title}`}>
                        <Truncate lines={1} >{doc.text} </Truncate>
                    </p>
                    <div className="flex-20 layout-row layout-align-center-center" onClick={() => this.deleteDoc(doc.doc_type)}>
                        <i className="fa fa-trash" />
                    </div>
                </div>
            );
        };
        const insuranceBox = (

            <div className={`flex-100 layout-row ${defaults.padd_top} ${styles.box_content} ${this.state.insuranceView ? styles.show : ''}`}>
                <div className="flex-80 layout-row layout-wrap">
                    <p className="flex-90">
                        <strong> Sign an insurance for the replacement of the goods shipped in case of total or partial loss or damage. The price of the insurance will be determined by the goods value and the transport charges.
                        </strong>
                    </p>
                    <p className="flex-90">
                  Note that if you choose not to pay to insure your shipment, the goods shipped are automatically covered under legal liability standard to the transportation industry.
                    </p>
                </div>
                <div className={` ${styles.prices} flex-20 layout-row layout-wrap`}>
                    <h5 className="flex-100"> Price </h5>
                    <h6 className="flex-100"> {insurance.val.toFixed(2)} €</h6>
                </div>
            </div>
        );
        const customsBox = (
            <div className={`flex-100 layout-row layout-wrap ${defaults.padd_top} ${styles.box_content} ${this.state.customsView ? styles.show : styles.hidden}`}>
                <div className="flex-80 layout-row layout-wrap">
                    <p className="flex-90">
                        <strong> {' '} Customs Clearance is the documented permission to pass that a national customs authority grants to imported goods so that they can enter the country o to exported goods so that they can leave the country.
                        </strong>
                    </p>
                    <p className="flex-90">
                  The customs clearance is typically given to a shipping agent to prove that all applicable customs duties have been paid and the shipment has been appoved.
                    </p>
                </div>
                <div className={` ${styles.prices} flex-20 layout-row layout-wrap`}>
                    <h5 className="flex-100"> Price </h5>
                    <h6 className="flex-100"> {customs ? this.calcCustomsFee() : '18.50'} €</h6>
                </div>
                <HSCodeRow containers={containers} cargoItems={cargoItems} theme={theme} setCode={setHsCode} deleteCode={deleteCode} hsCodes={hsCodes} />
            </div>
        );
        const noCustomsBox = (
            <div className={`flex-100 layout-row layout-align-start-center ${styles.no_customs_box} ${this.state.showNoCustoms ? styles.show : ''}`}>
                <div className="flex-33-layout-row layout-align-center-center">
                    <div className="flex-90 layout-row layout-wrap">
                        <div className="flex-100">
                            <p className={`flex-none ${styles.f_header}`}>
                                {' '}
                                    Customs Declaration
                            </p>
                        </div>
                        <div className="flex-100">
                            { documents.customs_declaration ?
                                <DocViewer doc={documents.customs_declaration} /> :
                                <FileUploader
                                    theme={theme}
                                    dispatchFn={this.fileFn}
                                    type="customs_declaration"
                                    text="Customs Declaration"
                                />}
                        </div>
                    </div>
                </div>
                <div className="flex-33-layout-row layout-align-center-center">
                    {this.props.totalGoodsValue > 20000 ? (
                        <div className="flex-90 layout-row layout-wrap">
                            <div className="flex-100">
                                <p className={`flex-none ${styles.f_header}`}>
                                    {' '}
                                    Customs Value Declaration
                                </p>
                            </div>
                            <div className="flex-100">
                                { documents.customs_value_declaration ?
                                    <DocViewer doc={documents.customs_value_declaration} /> :
                                    <FileUploader
                                        theme={theme}
                                        dispatchFn={this.fileFn}
                                        type="customs_value_declaration"
                                        text="Customs Value Declaration"
                                    />}
                            </div>
                        </div>
                    ) : (
                        ''
                    )}
                </div>
                <div className="flex-33-layout-row layout-align-center-center">
                    <div className="flex-90 layout-row layout-wrap">
                        <div className="flex-100">
                            <p className={`flex-none ${styles.f_header}`}> EORI</p>
                        </div>
                        <div className="flex-100">
                            { documents.eori ?
                                <DocViewer doc={documents.eori} /> :
                                <FileUploader theme={theme} dispatchFn={this.fileFn} type="eori" text="EORI"/>
                            }
                        </div>
                    </div>
                </div>
            </div>
        );
        return(
            <div className="flex-100 layout-row layout-wrap padd_top">
                <div className="flex-100 layout-row layout-align-center">
                    <div className={`flex-none ${defaults.content_width} layout-row layout-wrap`}>
                        <div className="flex-100 layout-row">
                            <p className={`flex-none ${styles.f_header}`}> Cargo Details</p>
                        </div>
                        <div className="flex-100 layout-row layout-wrap">
                            <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap alyout-align-start-start">
                                <div className="flex-100 layout-row layout-wrap">
                                    <div className="flex-100">
                                        <p
                                            className={`flex-none ${
                                                styles.f_header
                                            }`}
                                        >
                                            {' '}
                                            Total Value of Goods
                                        </p>
                                    </div>
                                    <div className="flex-100">
                                        <input
                                            className={styles.cargo_input}
                                            type="number"
                                            name="totalGoodsValue"
                                            value={this.props.totalGoodsValue}
                                            onChange={this.handleChange}
                                        />
                                    </div>
                                </div>
                                <div className="flex-100 layout-row layout-wrap">
                                    <div className="flex-100">
                                        <p
                                            className={`flex-none ${
                                                styles.f_header
                                            }`}
                                        >
                                            {' '}
                                            Number and kind of packages,
                                            description of goods
                                        </p>
                                    </div>
                                    <div className="flex-100">
                                        <textarea
                                            className={styles.cargo_text_area}
                                            rows="6"
                                            name="cargoNotes"
                                            value={this.props.cargoNotes}
                                            onChange={this.handleChange}
                                        />
                                    </div>
                                </div>
                            </div>
                            <div className="flex-100 flex-gt-sm-45 offset-gt-sm-5 layout-row layout-wrap alyout-align-start-start">
                                <div className="flex-100 layout-row">

                                    <p
                                        className={`flex-none ${
                                            styles.f_header
                                        }`}
                                    >
                                        {' '}
                                        Required Documents
                                    </p>
                                </div>

                                <div className="flex-50 layout-row layout-wrap">
                                    <div className="flex-100">
                                        <p
                                            className={`flex-none ${
                                                styles.f_header
                                            }`}
                                        >
                                            {' '}
                                                Packing Sheet
                                        </p>
                                    </div>
                                    <div className="flex-100">
                                        { documents.packing_sheet ?
                                            <DocViewer doc={documents.packing_sheet} /> :
                                            <FileUploader
                                                theme={theme}
                                                type="packing_sheet"
                                                dispatchFn={this.fileFn}
                                                text="Packing Sheet"
                                            />
                                        }
                                    </div>
                                </div>

                                <div className="flex-50 layout-row layout-wrap">
                                    <div className="flex-100">
                                        <p
                                            className={`flex-none ${
                                                styles.f_header
                                            }`}
                                        >
                                            {' '}
                                                Commercial Invoice
                                        </p>
                                    </div>
                                    <div className="flex-100">
                                        { documents.commercial_invoice ?
                                            <DocViewer doc={documents.commercial_invoice} /> :
                                            <FileUploader
                                                theme={theme}
                                                type="commercial_invoice"
                                                dispatchFn={this.fileFn}
                                                text="Commercial Invoice"
                                            />}
                                    </div>
                                </div>

                                <div className="flex-50 layout-row layout-wrap">
                                    <div className="flex-100">
                                        <p
                                            className={`flex-none ${
                                                styles.f_header
                                            }`}
                                        >
                                                Certificate of Origin
                                        </p>
                                    </div>
                                    <div className="flex-100">
                                        { documents.certificate_of_origin ?
                                            <DocViewer doc={documents.certificate_of_origin} /> :
                                            <FileUploader
                                                theme={theme}
                                                type="certificate_of_origin"
                                                dispatchFn={this.fileFn}
                                                text="Certificate of Origin"
                                            />}
                                    </div>
                                </div>
                                {dangerousGoods ? (
                                    <div className="flex-50 layout-row layout-wrap">
                                        <div className="flex-100">
                                            <p
                                                className={`flex-none ${
                                                    styles.f_header
                                                }`}
                                            >
                                                {' '}
                                                Dangerous Goods Declaration
                                            </p>
                                        </div>
                                        <div className="flex-100">
                                            { documents.dangerous_goods ?
                                                <DocViewer doc={documents.dangerous_goods} /> :
                                                <FileUploader
                                                    theme={theme}
                                                    type="dangerous_goods"
                                                    dispatchFn={this.fileFn}
                                                    text="Dangerous Goods Declaration"
                                                />}
                                        </div>
                                    </div>
                                ) : (
                                    ''
                                )}
                            </div>
                        </div>
                    </div>
                </div>
                <div className="flex-100 layout-row layout-align-center padd_top">

                    <div className={`flex-none ${defaults.content_width} layout-row layout-wrap`}>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <h4 className="flex-none">Insurance</h4>
                            <Checkbox onChange={this.toggleInsurance} checked={this.state.insuranceView} theme={theme} />
                        </div>
                        {insuranceBox}
                    </div>
                </div>
                <div className="flex-100 layout-row layout-align-center padd_top">

                    <div className={`flex-none ${defaults.content_width} layout-row layout-wrap`}>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <h4 className="flex-none">Customs</h4>
                            <Checkbox onChange={this.toggleCustoms} checked={this.state.customsView} theme={theme} />
                        </div>
                        {customsBox}
                        {noCustomsBox}
                    </div>
                </div>
            </div>
        );
    }
}
CargoDetails.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    handleChange: PropTypes.func,
    hsCode: PropTypes.string,
    cargoNotes: PropTypes.string,
    totalGoodsValue: PropTypes.number,
    handleInsurance: PropTypes.func,
    insurance: PropTypes.object
};
