# frozen_string_literal: true

require "mimemagic"
require "mimemagic/overlay"

config = ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", [[0, "PK\003\004", [[0..5000, "xl/"]]]]]
MimeMagic.add config[0], {magic: config[1]}
