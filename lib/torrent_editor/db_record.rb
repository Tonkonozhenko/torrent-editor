require 'active_record'

module TorrentEditor
  class DbRecord < ActiveRecord::Base
    self.table_name = 'torrents'
  end
end