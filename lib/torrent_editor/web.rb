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
      slim :index, layout: :application
    end

    post '/' do
      torrent = Torrent.new(params[:file][:tempfile])
      torrent.save
      redirect "/#{torrent.row.id}"
    end

    get '/:id' do
      @torrent = Torrent.find(params['id'])
      slim :show, layout: :application
    end

    get '/:id/download' do
      content_type 'application/x-bittorrent'
      torrent = Torrent.find(params['id'])
      headers['Content-Disposition'] = "attachment;filename=#{torrent.name}.torrent"
      torrent.to_torrent
    end

    def torrent_files_params
      params[:files].inject({}) do |hsh, (_, v)|
        key = v['old_path']
        hsh[key] = v.slice('length', 'md5sum', '_destroy')
        hsh[key]['path'] = v['path'].split('/')
        hsh[key]['length'] = hsh[key]['length'].to_i if hsh[key]['length'].present?
        hsh
      end
    end

    post '/:id' do
      torrent = Torrent.find(params['id'])

      opts = params.slice(*%w[name comment created_by encoding creation_date])
      opts[:announce_list] = params[:announce_list].split("\n").map { |e| [e] }
      torrent.update(opts)

      # Save attributes for files
      files_params = torrent_files_params

      # Collect files that should be deleted
      files_to_delete = []
      torrent.files.each do |file|
        path = file.path.join('/')
        attrs = files_params[path]
        # Remove file if it is marked as destroyed
        if attrs['_destroy'] == 'true'
          files_to_delete << file
        else
          file.update(attrs)
        end
        files_params.delete path
      end
      torrent.files -= files_to_delete

      # Add new files to torrent
      # TODO

      # Save whole torrent
      torrent.save

      redirect "/#{torrent.row.id}"
    end
  end
end