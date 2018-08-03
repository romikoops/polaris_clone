const options = {
  trucking: [
    {
      text: 'No Trucking',
      values: {
        pre_carriage: false,
        on_carriage: false
      }
    },
    {
      text: 'Pickup Only',
      values: {
        pre_carriage: true,
        on_carriage: false
      }
    },
    {
      text: 'Delivery Only',
      values: {
        pre_carriage: false,
        on_carriage: true
      }
    },
    {
      text: 'Pickup & Delivery',
      values: {
        pre_carriage: true,
        on_carriage: true
      }
    }
  ]
}

export default options
