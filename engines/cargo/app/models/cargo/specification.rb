module Cargo
  class Specification
    CARGO_LENGTH = %w(0 1 2 3 4 A B C D E F G H K L M N P).freeze
    CARGO_HEIGHT = %w(0 2 4 5 6 8 9 C L D M F P).freeze
    CARGO_TYPES = %w(LCL GP G0 G1 G2 G3 VH V0 V2 V4 BU B0 B1 BK B3 B4 B5 B6 SN S0 S1 S2 RE R0 RT R1 RS R2 HR H0 H1 H2 HI H5 H6 UT U0 U1 U2
                     U3 U4 U5 PL P0 PF P1 P2 PC P3 P4 PS P5 TN T0 T1 T2 TD T3 T4 T5 T6 TG T7 T8 T9 AO).freeze
    CLASS_ENUM_HASH = CARGO_LENGTH.product(CARGO_HEIGHT)
                                  .each_with_index
                                  .each_with_object({}) do |(arr, i), hash|
                                    hash[2**i] = arr.join
                                  end
    TYPE_ENUM_HASH = CARGO_TYPES.each_with_index.each_with_object({}) { |(arr, i), hash| hash[2**i] = arr }
    AREA_DIVISOR = 10_000
    DEFAULT_HEIGHT = 130
    LOAD_METERAGE_AREA_DIVISOR = 2.4
    CBM_VOLUME_DIVISOR = 1_000_000
  end
end
