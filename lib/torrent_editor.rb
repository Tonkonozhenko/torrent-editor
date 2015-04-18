require 'open-uri'
require 'bencode'
require 'active_record'
require 'active_support'

require_relative 'torrent_editor/core_ext/nil_class'
require_relative 'torrent_editor/torrent_file'
require_relative 'torrent_editor/torrent'
require_relative 'torrent_editor/web'

module TorrentEditor
  VERSION = '0.1.0'
end