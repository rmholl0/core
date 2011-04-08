require 'daitss/archive'
require 'daitss/archive/report'
require 'net/smtp'

module Daitss

  class Archive
    def email_report package
      account = package.project.account

      marker = rand(1000000000000)

msg = <<EOF
From: DAITSS <do_not_reply@fcla.edu>
To: DAITSS Account #{account.id} <#{account.report_email}>
Subject: Florida Digital Archive Report
Date: #{Time.now.to_s}
Content-Type: multipart/mixed; boundary="#{marker}"

--#{marker}
Content-Type: text/plain

Ingest of package #{package.sip.name}
--#{marker}
Content-Type: text/xml; name="#{package.id}.ingest.xml"

#{ingest_report package.id}

--#{marker}--
EOF

      Net::SMTP.start("localhost") do |smtp|
        smtp.send_message msg, 'do_not_reply@fcla.edu', account.report_email
      end
    end

    def email_reject_report package
      account = package.project.account

      marker = rand(1000000000000)

msg = <<EOF
From: DAITSS <do_not_reply@fcla.edu>
To: DAITSS Account #{account.id} <#{account.report_email}>
Subject: Florida Digital Archive Report
Date: #{Time.now.to_s}
Content-Type: multipart/mixed; boundary="#{marker}"

--#{marker}
Content-Type: text/plain

#{package.events.first(:name => "reject").notes}
--#{marker}
Content-Type: text/xml; name="#{package.id}.error.xml"

#{reject_report package.id}

--#{marker}--
EOF

      Net::SMTP.start("localhost") do |smtp|
        smtp.send_message msg, 'do_not_reply@fcla.edu', account.report_email
      end
    end

  end
end
 
