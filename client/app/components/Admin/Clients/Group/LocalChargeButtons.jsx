import React from 'react'
import FileUploader from '../../../FileUploader/FileUploader'

const PricingButtons = (props) => {
  const {
    t, theme, uploadFn
  } = props

  return (
    <div className="flex-100 layout-row layout-align-center-start layout-wrap margin_5">
      <div className="flex-100 layout-row layout-align-center padd_5">
        <FileUploader
          text={t('admin:uploadGroupLocalCharges')}
          theme={theme}
          dispatchFn={file => uploadFn(file)}
          size="small"
          active
          square
        />
      </div>
    </div>
  )
}

export default PricingButtons
