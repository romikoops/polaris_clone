function getShipmentData (response, stage) {
  return (response && stage && response[`stage${stage - 1}`]) || {}
}

function hasNextStage (response, stage) {
  return response && stage && response[`stage${stage}`]
}

const stageActions = {
  getShipmentData,
  hasNextStage
}

export default stageActions
