require 'cgi'
require 'libxml'

include LibXML

module Provenance
  
  def provenance_retrieved?
    type = "External Provenance Extraction"
    
    md_for(:digiprov).any? do |doc|
      doc.find_first("//premis:event[premis:eventType[normalize-space(.)='#{type}']]", NS_MAP)
    end
  end

  def retrieve_provenance
    s_url = "http://localhost:7000/provenance/events?location=#{CGI::escape @url.to_s}"
    extp_doc = open(s_url) { |resp| XML::Parser.io(resp).parse }
    add_md :digiprov, extp_doc
  end
  
end