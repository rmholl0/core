require 'tempfile'
require 'fileutils'

class Tempdir

  attr_reader :path

  def initialize
    t = Tempfile.new 'tempdir'
    @path = t.path
    t.close!
    FileUtils::mkdir @path
    yield self if block_given?
  end

  def rmdir
    FileUtils::rmdir @path
  end

  def rm_rf
    FileUtils::rm_rf @path
  end

  def to_s
    @path
  end

end
