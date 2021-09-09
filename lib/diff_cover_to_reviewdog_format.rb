# frozen_string_literal: true

require "json"

file = File.read(ARGV[0])
report_data = JSON.parse file

reviewdog_hash = {
  source: {
    name: "diff cover",
    url: "https://github.com/Bachmann1234/diff_cover"
  },
  severity: "ERROR",
  diagnostics: []
}

mapped = report_data["src_stats"]
  .map { |path, content| { path => content["violation_lines"] } }
  .reduce(:merge)
filtered = mapped.reject { |_path, violations| violations.empty? }
final = filtered.flat_map do |path, violations|
  violations.map do |line_nr|
    {
      message: "Test coverage missing",
      location: {
        path: path,
        range: {
          start: {
            line: line_nr
          }
        }
      },
      severity: "ERROR"
    }
  end
end

reviewdog_hash[:diagnostics] = final
$stdout.puts reviewdog_hash.to_json
