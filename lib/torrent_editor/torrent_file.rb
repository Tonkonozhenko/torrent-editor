# =Class for presenting each file in Torrent
module TorrentEditor
  class TorrentFile < ActiveRecord::Base
    # Default order
    default_scope -> { order('id ASC') }

    # Attributes
    ATTRIBUTES = %i[length md5sum path]

    # DB associations
    belongs_to :torrent
  end
end