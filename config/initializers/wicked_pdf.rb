# WKHTMLTOPDF_BINARIES_PATH = "#{Rails.root}/bin/wkhtmltopdf/"
WKHTMLTOPDF_BINARIES_PATH = "https://assets.itsmycargo.com/assets/binaries/wkhtmltopdf/"

if OS.host_cpu == "x86_64" && OS.linux?
  WickedPdf.config = { exe_path: WKHTMLTOPDF_BINARIES_PATH + "wkhtmltopdf-0.12.3_linux-generic-amd64" }
elsif OS.host_cpu == "x86_64" && OS.mac?
  WickedPdf.config = { exe_path: WKHTMLTOPDF_BINARIES_PATH + "wkhtmltopdf-0.12.3_osx-cocoa-x86-64" }
elsif OS.host_cpu == "i386" && OS.linux?
  WickedPdf.config = { exe_path: WKHTMLTOPDF_BINARIES_PATH + "wkhtmltopdf-0.12.3_linux-generic-i386" }
else
  raise "UnableToLocateWkhtmltopdf"
end