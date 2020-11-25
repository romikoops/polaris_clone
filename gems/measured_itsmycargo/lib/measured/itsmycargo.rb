# frozen_string_literal: true

Measured::Area = Measured.build {
  unit :m2

  unit :ft2,
    value: "0.092903 m2"
}

Measured::StowageFactor = Measured.build {
  unit "m3/t"
}

Measured::Quantity = Measured.build {
  unit "pcs"
}

Measured::WeightMeasure = Measured.build {
  unit "t/m3"
}
