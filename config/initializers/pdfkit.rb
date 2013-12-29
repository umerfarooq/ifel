# config/initializers/pdfkit.rb
PDFKit.configure do |config|
  config.wkhtmltopdf = '/usr/bin/wkhtmltopdf'
  config.default_options = {
    :page_size => 'Legal',
    :print_media_type => true,
    :footer_right => "Page [page] of [toPage]",
    :footer_center => "Powered by Wicked Start.com"

  }
  #   config.root_url = "http://localhost" # Use only if your external hostname is unavailable on the server.
end