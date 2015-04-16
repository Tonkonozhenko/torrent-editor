require_relative 'lib/torrent_editor/web'

run Rack::URLMap.new('/' => TorrentEditor::Web)