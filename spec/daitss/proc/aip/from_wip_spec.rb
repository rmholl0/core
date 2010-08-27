require 'spec_helper'

require 'daitss/model/aip'
require 'daitss/model/aip/from_wip'
require 'daitss/proc/wip/from_aip'
require 'daitss/proc/wip/ingest'
require 'daitss/proc/wip/preserve'

describe Aip do

  it "should create a new AIP from a WIP" do
    wip = submit 'mimi'
    wip.preserve!
    wip['aip-descriptor'] = wip.descriptor

    spec = {
      :id => "#{wip.uri}/event/ingest",
      :type => 'ingest',
      :outcome => 'success',
      :linking_objects => [ wip.uri ]
    }

    wip['ingest-event'] = event spec
    wip['aip-descriptor'] = wip.descriptor
    Aip::new_from_wip wip

    Package.get(wip.id).aip.should_not be_nil
  end

  describe "that does not exist" do
    subject { submit 'mimi' }

    it "should not update from a wip" do
      lambda {
        Aip.update_from_wip subject
      }.should raise_error(DataMapper::ObjectNotFoundError)
    end

  end

  describe "that exists" do

    subject do
      proto_wip = submit 'mimi'
      proto_wip.ingest!
      path = proto_wip.path
      FileUtils.rm_r path
      wip = Wip.from_aip path
      wip.preserve!

      spec = {
        :id => "#{wip.uri}/event/FOO",
        :type => 'FOO',
        :outcome => 'success',
        :linking_objects => [ wip.uri ]
      }

      wip['old-digiprov-events'] = wip['old-digiprov-events'] + "\n" + event(spec)

      wip['aip-descriptor'] = wip.descriptor
      Aip.update_from_wip wip
      Package.get(wip.id).aip.should_not be_nil
    end

    it "should update from a WIP" do
      Package.get(subject.id).aip.should_not be_nil
    end

    it "should have new metadata" do
      doc = XML::Document.string subject.xml
      doc.find("//P:event/P:eventType = 'FOO'", NS_PREFIX).should be_true
    end

  end


end
