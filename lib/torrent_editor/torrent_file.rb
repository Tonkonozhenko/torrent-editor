module TorrentEditor
  class TorrentFile < ActiveRecord::Base
    default_scope -> { order('id ASC') }

    ATTRIBUTES = %i[length md5sum path]

    belongs_to :torrent
  end
end