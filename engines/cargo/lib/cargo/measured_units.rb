# frozen_string_literal: true

Measured::Area = Measured.build do
  unit :m2

  unit :ft2,
       value: '0.092903 m2'
end

Measured::StowageFactor = Measured.build do
  unit 'm3/t'
end

Measured::WeightMeasure = Measured.build do
  unit 't/m3'
end
