import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './CargoDetails.scss';
import { Checkbox } from '../Checkbox/Checkbox';
import FileUploader from '../FileUploader/FileUploader';

export class CargoDetails extends Component {
    constructor(props) {
        super(props);
        this.state = {
            insuranceView: true,
            customsView: true,
            hsCode: '',
            cargoNotes: '',
            totalGoodsValue: 0
        };
        this.toggleInsurance = this.toggleInsurance.bind(this);
        this.toggleCustoms = this.toggleCustoms.bind(this);
        this.handleChange = this.handleChange.bind(this);
    }
    toggleInsurance() {
        this.setState({ insuranceView: !this.state.insuranceView });
        this.props.handleInsurance();
    }
    toggleCustoms() {
        this.setState({ customsView: !this.state.customsView });
    }
    handleChange(event) {
        // const { name, value } = event.target;
        // this.setState({[name]: value});
        this.props.handleChange(event);
    }
    render() {
        const { shipmentData, theme } = this.props;
        const { shipment, dangerousGoods } = shipmentData;
        const packUrl = shipmentData
            ? '/shipments/' + shipment.id + '/upload/packing_sheet'
            : '';
        const cInvUrl = shipmentData
            ? '/shipments/' + shipment.id + '/upload/commercial_invoice'
            : '';
        const custDec = shipmentData
            ? '/shipments/' + shipment.id + '/upload/customs_declaration'
            : '';
        const custVal = shipmentData
            ? '/shipments/' + shipment.id + '/upload/customs_value_declaration'
            : '';
        const eori = shipmentData
            ? '/shipments/' + shipment.id + '/upload/eori'
            : '';
        const certOrigin = shipmentData
            ? '/shipments/' + shipment.id + '/upload/certificate_of_origin'
            : '';
        const dGoods = shipmentData
            ? '/shipments/' + shipment.id + '/upload/dangerous_goods'
            : '';
        const insuranceVal = shipmentData
            ? (shipment.total_price + this.state.totalGoodsValue) * 1.1 * 0.17
            : 0;
        const insuranceBox = (
            <div className="flex-100 layout-row padd_top">
                <div className="flex-80 layout-row layout-wrap">
                    <p className="flex-90">
                        <strong>
                            {' '}
                            Sign an insurance for the replacement of the goods
                            shipped in case of total or partial loss or damage.
                            The price of the insurance will be determined by the
                            goods value and the transport charges.
                        </strong>
                    </p>
                    <p className="flex-90">
                        Note that if you choose not to pay to insure your
                        shipment, the goods shipped are automatically covered
                        under legal liability standard to the transportation
                        industry.
                    </p>
                </div>
                <div
                    className={` ${
                        styles.prices
                    } flex-20 layout-row layout-wrap`}
                >
                    <h5 className="flex-100"> Price </h5>
                    <h6 className="flex-100"> {insuranceVal.toFixed(2)} €</h6>
                </div>
            </div>
        );
        const customsBox = (
            <div className="flex-100 layout-row padd_top">
                <div className="flex-80 layout-row layout-wrap">
                    <p className="flex-90">
                        <strong>
                            {' '}
                            Customs Clearance is the documented permission to
                            pass that a national customs authority grants to
                            imported goods so that they can enter the country o
                            to exported goods so that they can leave the
                            country.
                        </strong>
                    </p>
                    <p className="flex-90">
                        The customs clearance is typically given to a shipping
                        agent to prove that all applicable customs duties have
                        been paid and the shipment has been appoved.
                    </p>
                </div>
                <div
                    className={` ${
                        styles.prices
                    } flex-20 layout-row layout-wrap`}
                >
                    <h5 className="flex-100"> Price </h5>
                    <h6 className="flex-100"> 18.50 €</h6>
                </div>
            </div>
        );
        const noCustomsBox = (
            <div className="flex-100 layout-row layout-align-start-center">
                <div className="flex-33-layout-row layout-align-center-center">
                    {custDec ? (
                        <div className="flex-90 layout-row layout-wrap">
                            <div className="flex-100">
                                <p className={`flex-none ${styles.f_header}`}>
                                    {' '}
                                    Customs Declaration
                                </p>
                            </div>
                            <div className="flex-100">
                                <FileUploader
                                    theme={theme}
                                    url={custDec}
                                    type="customs_declaration"
                                    text="Customs Declaration"
                                />
                            </div>
                        </div>
                    ) : (
                        ''
                    )}
                </div>
                <div className="flex-33-layout-row layout-align-center-center">
                    {custVal && this.props.totalGoodsValue > 20000 ? (
                        <div className="flex-90 layout-row layout-wrap">
                            <div className="flex-100">
                                <p className={`flex-none ${styles.f_header}`}>
                                    {' '}
                                    Customs Value Declaration
                                </p>
                            </div>
                            <div className="flex-100">
                                <FileUploader
                                    theme={theme}
                                    url={custVal}
                                    type="customs_value_declaration"
                                    text="Customs Value Declaration"
                                />
                            </div>
                        </div>
                    ) : (
                        ''
                    )}
                </div>
                <div className="flex-33-layout-row layout-align-center-center">
                    {eori ? (
                        <div className="flex-90 layout-row layout-wrap">
                            <div className="flex-100">
                                <p className={`flex-none ${styles.f_header}`}>
                                    {' '}
                                    EORI
                                </p>
                            </div>
                            <div className="flex-100">
                                <FileUploader
                                    theme={theme}
                                    url={eori}
                                    type="eori"
                                    text="EORI"
                                />
                            </div>
                        </div>
                    ) : (
                        ''
                    )}
                </div>
            </div>
        );
        return (
            <div className="flex-100 layout-row layout-wrap padd_top">
                <div className="flex-100 layout-row layout-align-center">
                    <div className="flex-none content-width layout-row layout-wrap">
                        <div className="flex-100 layout-row">
                            <p className={`flex-none ${styles.f_header}`}>
                                {' '}
                                Cargo Details
                            </p>
                        </div>
                        <div className="flex-100 layout-row layout-wrap">
                            <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap alyout-align-start-start">
                                <div className="flex-50 layout-row layout-wrap">
                                    <div className="flex-100">
                                        <p className="flex-none"> HS Code</p>
                                    </div>
                                    <div className="flex-100">
                                        <input
                                            className={styles.cargo_input}
                                            type="text"
                                            name="hsCode"
                                            value={this.props.hsCode}
                                            onChange={this.handleChange}
                                        />
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
                                {packUrl ? (
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
                                            <FileUploader
                                                theme={theme}
                                                url={packUrl}
                                                type="packing_sheet"
                                                text="Packing Sheet"
                                            />
                                        </div>
                                    </div>
                                ) : (
                                    ''
                                )}
                                {cInvUrl ? (
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
                                            <FileUploader
                                                theme={theme}
                                                url={cInvUrl}
                                                type="commercial_invoice"
                                                text="Commercial Invoice"
                                            />
                                        </div>
                                    </div>
                                ) : (
                                    ''
                                )}
                                {certOrigin ? (
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
                                            <FileUploader
                                                theme={theme}
                                                url={certOrigin}
                                                type="commercial_invoice"
                                                text="Certificate of Origin"
                                            />
                                        </div>
                                    </div>
                                ) : (
                                    ''
                                )}
                                {dGoods && dangerousGoods ? (
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
                                            <FileUploader
                                                theme={theme}
                                                url={dGoods}
                                                type="commercial_invoice"
                                                text="Dangerous Goods Declaration"
                                            />
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
                    <div className="flex-none content-width layout-row layout-wrap">
                        <div className="flex-100 layout-row layout-align-start-center">
                            <h4 className="flex-none">Insurance</h4>
                            <Checkbox
                                onChange={this.toggleInsurance}
                                checked={this.state.insuranceView}
                            />
                        </div>
                        {this.state.insuranceView ? insuranceBox : ''}
                    </div>
                </div>
                <div className="flex-100 layout-row layout-align-center padd_top">
                    <div className="flex-none content-width layout-row layout-wrap">
                        <div className="flex-100 layout-row layout-align-start-center">
                            <h4 className="flex-none">Customs</h4>
                            <Checkbox
                                onChange={this.toggleCustoms}
                                checked={this.state.customsView}
                            />
                        </div>
                        {this.state.customsView ? customsBox : noCustomsBox}
                    </div>
                </div>
            </div>
        );
    }
}
CargoDetails.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    handleChange: PropTypes.func,
    hsCode: PropTypes.string,
    cargoNotes: PropTypes.string,
    totalGoodsValue: PropTypes.number
};
