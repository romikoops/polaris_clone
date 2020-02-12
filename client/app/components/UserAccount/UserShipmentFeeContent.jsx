import React from 'react'

function UserShipmentFeeContent (props) {
  const { feeHashType } = props

  return (
    <div className="flex layout-row layout-align-end-center">
      {feeHashType && (
        <p>
          {feeHashType.edited_total && parseFloat(feeHashType.edited_total.value).toFixed(2)}
          {feeHashType.edited_total && feeHashType.edited_total.currency}
          {feeHashType.total && parseFloat(feeHashType.total.value).toFixed(2)}
          {feeHashType.total && feeHashType.total.currency}
        </p>
      )}
    </div>
  )
}

export default UserShipmentFeeContent
