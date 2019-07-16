import React from 'react'
import SquareButton from '../../../SquareButton'
import FileUploader from '../../../FileUploader/FileUploader'

const MarginButtons = (props) => {
  const {
    t, theme, toggleEdit, newFn, uploadFn
  } = props

  return (
    <div className="flex-100 layout-row layout-align-center-start layout-wrap">
      <div className="flex-100 layout-row layout-align-center-center margin_5">
        <SquareButton
          text={t('admin:editMargins')}
          theme={theme}
          handleNext={() => toggleEdit()}
          size="small"
          border
          active
        />
      </div>
      <div className="flex-100 layout-row layout-align-center-center margin_5">
        <SquareButton
          text={t('admin:newMargins')}
          theme={theme}
          handleNext={() => newFn()}
          size="small"
          border
          active
        />
      </div>
      <div className="flex-100 layout-row layout-align-center-center margin_5">
        <FileUploader
          text={t('admin:uploadGroupMargins')}
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

export default MarginButtons
