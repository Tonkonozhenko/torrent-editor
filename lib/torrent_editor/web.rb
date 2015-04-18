require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'padrino-helpers'

require 'slim'
require 'better_errors'

require_relative '../torrent_editor'

# =Web requests handler
module TorrentEditor
  class Web < Sinatra::Base
    register Padrino::Helpers
    register Sinatra::ActiveRecordExtension

    set :root, File.expand_path(File.dirname(__FILE__) + '/../../web')
    set :public_folder, -> { "#{root}/assets" }
    set :views, proc { "#{root}/views" }
    set :database_file, "#{File.expand_path(root + '/..')}/config/database.yml"
    set :protect_from_csrf, false
    set :lock, false

    configure :development do
      register Sinatra::Reloader
      also_reload 'lib/torrent_editor/**/*.rb'

      use BetterErrors::Middleware
      BetterErrors.application_root = File.expand_path('../..', __FILE__)
    end

    # Params for creating new torrent and updating existing one
    def permitted_params
      opts = params['torrent']
      opts['files_attributes'].each { |_, v| v['path'] = v['path'].split('/') }
      opts
    end

    def destroyable_files
      @destroyable_files ||= params['torrent']['files_attributes'].select { |_, v| v['_destroy'] == 'true' }.map { |_, v| v['id'].to_i }
    end

    # Index page
    get '/' do
      @torrents = Torrent.all
      slim :index, layout: :application
    end

    post '/' do
      torrent = Torrent.create(params[:file][:tempfile])
      redirect "/#{torrent.id}"
    end

    # Generating new torrent from zero
    get '/new' do
      @torrent = Torrent.new({})
      @url = '/new'
      slim :show
    end

    post '/new' do
      @torrent = Torrent.new(permitted_params)

      if @torrent.save
        redirect "/#{@torrent.id}"
      else
        @url = '/new'
        slim :show
      end
    end

    # Show torrent page
    get '/:id' do
      @torrent = Torrent.find(params['id'])
      slim :show, layout: :application
    end

    # Download torrent
    get '/:id/download' do
      content_type 'application/x-bittorrent'
      torrent = Torrent.find(params['id'])
      headers['Content-Disposition'] = "attachment;filename=#{torrent.name}.torrent"
      torrent.to_torrent
    end

    # Update torrent
    post '/:id' do
      torrent = Torrent.find(params['id'])
      torrent.assign_attributes(permitted_params)
      torrent.files.each do |file|
        destroyable_files.index(file.id) ? file.destroy : file.save
      end
      torrent.save
      redirect "/#{torrent.id}"
    end
  end
end