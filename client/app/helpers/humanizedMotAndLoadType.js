function humanizedMotAndLoadType (scope, loadType) {
  const converter = {
    ocean: {
      container: 'Ocean FCL',
      cargo_item: 'Ocean LCL'
    },
    rail: {
      container: 'Rail FCL',
      cargo_item: 'Rail LCL'
    },
    truck: {
      container: 'Trucking FTL',
      cargo_item: 'Trucking LTL'
    },
    air: {
      container: '',
      cargo_item: 'Air'
    }
  }

  const stringElems = Object.keys(scope.modes_of_transport)
    .filter(mot => scope.modes_of_transport[mot][loadType])
    .map(mot => converter[mot][loadType])
    .filter(mot => mot)
    .sort()

  let str = ''
  stringElems.forEach((elem, i) => {
    switch (i) {
      case stringElems.length - 1:
        str += elem
        break
      case stringElems.length - 2:
        str += `${elem} & `
        break
      default:
        str += `${elem}, `
    }
  })
  return str
}

export default humanizedMotAndLoadType
