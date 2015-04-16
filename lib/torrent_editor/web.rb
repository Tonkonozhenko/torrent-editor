require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/reloader'
require 'sinatra/activerecord'

require 'slim'
require 'better_errors'

require_relative '../torrent_editor'

module TorrentEditor
  class Web < Sinatra::Base
    register Sinatra::ActiveRecordExtension

    set :root, File.expand_path(File.dirname(__FILE__) + '/../../web')
    set :public_folder, -> { "#{root}/assets" }
    set :views, proc { "#{root}/views" }
    set :database_file, "#{File.expand_path(root + '/..')}/config/database.yml"

    configure :development do
      register Sinatra::Reloader
      also_reload 'lib/torrent_editor/**/*.rb'

      use BetterErrors::Middleware
      BetterErrors.application_root = File.expand_path('../..', __FILE__)
    end

    get '/' do
      @torrents = Torrent.all
      slim :index
    end

    post '/' do
      torrent = Torrent.new(params[:file][:tempfile])
      torrent.save
      redirect "/#{torrent.row.id}"
    end

    get '/:id' do
      @torrent = Torrent.find(params['id'])
      slim :show
    end

    get '/:id/download' do
      content_type 'application/x-bittorrent'
      row = Torrent.find(params['id']).row
      headers['Content-Disposition'] = "attachment;filename=#{row.name}.torrent"
      row.content
    end
  end
end