namespace :apiify do |args|
  desc "create a controller for api calls with routes, then check for a migration and a model"
  task :controller => :environment do
    import_file = Rails.root.join('lib', 'test_apiify_import_file.rb')


  end

  def create_api_controller(json_object)
    filename   = json_object[:model].to_s.pluralize.underscore + '_controller.rb'
    path       = Rails.root.join('app', 'controllers', 'api', 'vi', filename)

    unless File.exist?(path)
      Dir.mkdir(Rails.root.join('app', 'controllers', 'api', 'vi')) unless File.exists?(Rails.root.join('app', 'controllers', 'api'))

      safe_params = {}

      if json_object[:controller][:api][:routes].present? && json_object[:controller][:api][:strong_params].present?
        if json_object[:controller][:api][:strong_params].is_a?(Array)
          safe_params = json_object[:controller][:api][:strong_params]
        elsif json_object[:controller][:api][:strong_params] === :all
          if json_object[:attrs].present?
            safe_params = json_object[:attrs].keys
          end
        end
      end

      File.open(path, 'w+') do |f|
        f.write(<<-EOF.strip_heredoc)
          class Api::#{json_object[:model].to_s.pluralize.camelize}Controller < ApplicationController
            # Prevent CSRF attacks by raising an exception.
            # For APIs, you may want to use :null_session instead.
            # protect_from_forgery with: :exception

          #{if opts[:controller][:api][:routes].include?(:index)
            <<-eos

            def index
              render json: #{opts[:model].to_s.camelize}.all, status: 200
            end
            eos
            end
          }
          #{if opts[:routes].include?(:show)
            <<-eos

            def show
              render json: #{opts[:camel_name]}.find(params['id']), status: 200
            end
            eos
            end
          }
          #{if opts[:routes].include?(:create)
            <<-eos

            def create
              #{opts[:model]} = #{opts[:camel_name]}.create(safe_params)
              render json: #{opts[:model]}, status: 201
            end
            eos
            end
          }
          #{if opts[:routes].include?(:update)
            <<-eos

            def update
              #{opts[:model]} = #{opts[:camel_name]}.find(params['id'])
              #{opts[:model]}.update_attributes(safe_params)
              render nothing: true, status: 204
            end
            eos
            end
          }
          #{if opts[:routes].include?(:destroy)
            <<-eos

            def destroy
              #{opts[:model]} = #{opts[:camel_name]}.find(params['id'])
              #{opts[:model]}.destroy
              render nothing: true, status: 204
            end
            eos
            end
          }

            def #{opts[:model].to_s}_params
              params.require(:#{opts[:model].to_s}).permit(#{safe_params})
            end
          end
        EOF

        require 'fileutils'

        tempfile=File.open(Rails.root.join('config', 'temp.rb'), 'w')
        f=File.new(Rails.root.join('config', 'routes.rb'))

        insert_next = false

        f.each do |line|
          if insert_next
            insert_next = nil
            routes_key = {'i' => :index, 's' => :show, 'u' => :update, 'c' => :create, 'd' => :destroy}

            tempfile << "\t\tresources :#{opts[:camel_name].underscore.pluralize}, only: #{opts[:routes].map{|r| routes_key[r]}}\n"
          end

          if line=~ /namespace \:api/
            insert_next = true
          end

          tempfile<<line
        end

        f.close
        tempfile.close

        FileUtils.mv(Rails.root.join('config', 'temp.rb'), Rails.root.join('config', 'routes.rb'))
      end
    end

  end
  
  
    def create_standard_controller(json_object)
    filename   = json_object[:model].to_s.pluralize.underscore + '_controller.rb'
    path       = Rails.root.join('app', 'controllers', filename)

    unless File.exist?(path)

      safe_params = {}

      if json_object[:controller][:standard][:routes].present? && json_object[:controller][:standard][:strong_params].present?
        if json_object[:controller][:standard][:strong_params].is_a?(Array)
          safe_params = json_object[:controller][:standard][:strong_params]
        elsif json_object[:controller][:standard][:strong_params] === :all
          if json_object[:attrs].present?
            safe_params = json_object[:attrs].keys
          end
        end
      end

      all_routes = json_object[:controller][:standard][:total_overlord] || json_object[:controller][:standard][:routes] == :all

      File.open(path, 'w+') do |f|
        f.write(<<-EOF.strip_heredoc)
          class Api::#{json_object[:model].to_s.pluralize.camelize}Controller < ApplicationController
            # Prevent CSRF attacks by raising an exception.
            # For APIs, you may want to use :null_session instead.
            # protect_from_forgery with: :exception

          #{if all_routes || json_object[:controller][:standard][:routes].include?(:index)
            <<-eos

            def index
              render json: #{json_object[:model].to_s.camelize}.all, status: 200
            end
            eos
            end
          }
          #{if all_routes || json_object[:controller][:standard][:total_overlord] || json_object[:controller][:standard][:routes] == :all || json_object[:controller][:standard][:routes].include?(:show)
            <<-eos

            def show
              render json: #{json_object[:model].to_s.camelize}.find(params['id']), status: 200
            end
            eos
            end
          }
          #{if all_routes || json_object[:controller][:standard][:routes].include?(:create)
            <<-eos

            def create
              #{json_object[:model].to_s} = #{json_object[:model].to_s}.create(safe_params)
              render json: #{json_object[:model].to_s}, status: 201
            end
            eos
            end
          }
          #{if all_routes || json_object[:controller][:standard][:routes].include?(:update)
            <<-eos

            def update
              #{json_object[:model].to_s} = #{json_object[:model].to_s.camelize}.find(params['id'])
              #{json_object[:model].to_s}.update_attributes(safe_params)
              render nothing: true, status: 204
            end
            eos
            end
          }
          #{if all_routes || json_object[:controller][:standard][:routes].include?(:destroy)
            <<-eos

            def destroy
              #{json_object[:model].to_s} = #{json_object[:model].to_s.camelize}.find(params['id'])
              #{json_object[:model].to_s}.destroy
              render nothing: true, status: 204
            end
            eos
            end
          }

            def #{json_object[:model].to_s}_params
              params.require(:#{json_object[:model].to_s}).permit(#{safe_params})
            end
          end
        EOF

        require 'fileutils'

        tempfile=File.open(Rails.root.join('config', 'temp.rb'), 'w')
        f=File.new(Rails.root.join('config', 'routes.rb'))

        insert_next = false

        f.each do |line|
          if insert_next

            if all_routes
              tempfile << "\t\tresources :#{opts[:camel_name].underscore.pluralize}"
            elsif json_object[:controller][:standard][:routes].is_a?(Array)
              tempfile << "\t\tresources :#{opts[:camel_name].underscore.pluralize}, only: #{json_object[:controller][:standard][:routes]}}\n"
            end
          end

          tempfile<<line
        end

        f.close
        tempfile.close

        FileUtils.mv(Rails.root.join('config', 'temp.rb'), Rails.root.join('config', 'routes.rb'))
      end
    end

  end

  def create_admin_controller(json_object)
    filename   = json_object[:model].to_s.pluralize.underscore + '_controller.rb'
    path       = Rails.root.join('app', 'controllers', 'admin', 'vi', filename)

    unless File.exist?(path)
      Dir.mkdir(Rails.root.join('app', 'controllers', 'admin')) unless File.exists?(Rails.root.join('app', 'controllers', 'admin'))

      safe_params = {}

      if json_object[:controller][:admin][:routes].present? && json_object[:controller][:admin][:strong_params].present?
        if json_object[:controller][:admin][:strong_params].is_a?(Array)
          safe_params = json_object[:controller][:admin][:strong_params]
        elsif json_object[:controller][:admin][:strong_params] === :all
          if json_object[:attrs].present?
            safe_params = json_object[:attrs].keys
          end
        end
      end

      all_routes = json_object[:controller][:admin][:total_overlord] || json_object[:controller][:admin][:routes] == :all

      File.open(path, 'w+') do |f|
        f.write(<<-EOF.strip_heredoc)
          class Api::#{json_object[:model].to_s.pluralize.camelize}Controller < ApplicationController
            # Prevent CSRF attacks by raising an exception.
            # For APIs, you may want to use :null_session instead.
            # protect_from_forgery with: :exception

          #{if all_routes || json_object[:controller][:admin][:routes].include?(:index)
            <<-eos

            def index
              render json: #{json_object[:model].to_s.camelize}.all, status: 200
            end
            eos
            end
          }
          #{if all_routes || json_object[:controller][:admin][:total_overlord] || json_object[:controller][:admin][:routes] == :all || json_object[:controller][:admin][:routes].include?(:show)
            <<-eos

            def show
              render json: #{json_object[:model].to_s.camelize}.find(params['id']), status: 200
            end
            eos
            end
          }
          #{if all_routes || json_object[:controller][:admin][:routes].include?(:create)
            <<-eos

            def create
              #{json_object[:model].to_s} = #{json_object[:model].to_s}.create(safe_params)
              render json: #{json_object[:model].to_s}, status: 201
            end
            eos
            end
          }
          #{if all_routes || json_object[:controller][:admin][:routes].include?(:update)
            <<-eos

            def update
              #{json_object[:model].to_s} = #{json_object[:model].to_s.camelize}.find(params['id'])
              #{json_object[:model].to_s}.update_attributes(safe_params)
              render nothing: true, status: 204
            end
            eos
            end
          }
          #{if all_routes || json_object[:controller][:admin][:routes].include?(:destroy)
            <<-eos

            def destroy
              #{json_object[:model].to_s} = #{json_object[:model].to_s.camelize}.find(params['id'])
              #{json_object[:model].to_s}.destroy
              render nothing: true, status: 204
            end
            eos
            end
          }

            def #{json_object[:model].to_s}_params
              params.require(:#{json_object[:model].to_s}).permit(#{safe_params})
            end
          end
        EOF

        require 'fileutils'

        tempfile=File.open(Rails.root.join('config', 'temp.rb'), 'w')
        f=File.new(Rails.root.join('config', 'routes.rb'))

        insert_next = false

        f.each do |line|
          if insert_next
            insert_next = nil

            if all_routes
              tempfile << "\t\tresources :#{opts[:camel_name].underscore.pluralize}"
            elsif json_object[:controller][:admin][:routes].is_a?(Array)
              tempfile << "\t\tresources :#{opts[:camel_name].underscore.pluralize}, only: #{json_object[:controller][:admin][:routes]}}\n"
            end
          end

          if line=~ /namespace \:admin/
            insert_next = true
          end

          tempfile<<line
        end

        f.close
        tempfile.close

        FileUtils.mv(Rails.root.join('config', 'temp.rb'), Rails.root.join('config', 'routes.rb'))
      end
    end

  end
  
  
  def create_model(json_object)
    model_filename   = opts[:model] + '.rb'
    model_path       = Rails.root.join('app', 'models', model_filename)

    unless File.exist?(model_path)
      File.open(model_path, 'w+') do |f|
        f.write(<<-EOF.strip_heredoc)
          class #{opts[:camel_name]} < ActiveRecord::Base
            # has_many
            # belongs_to
          end
        EOF
      end
    end
  end

  def create_migration(json_object)
    require 'find'

    migration_exist = false
    Find.find("#{Rails.root.join('db', 'migrate')}/") do |filer|
      migration_exist = true if filer.include?("#{opts[:model].pluralize}.rb")
    end

    unless migration_exist
      filename     = "%s_%s.rb" % [Time.now.strftime('%Y%m%d%H%M%S'), "create_#{opts[:camel_name].underscore.pluralize}"]
      mig_path     = Rails.root.join('db', 'migrate', filename)
      arrayified_params = opts[:params].map.with_index {|param, index| "#{param[:type]}  :#{param[:name]}"}

      arrayified_params.unshift('')

      File.open(mig_path, 'w+') do |f|
        f.write(<<-EOF.strip_heredoc)
          class Create#{opts[:camel_name]} < ActiveRecord::Migration
            def change
              create_table :#{opts[:camel_name].underscore.pluralize} do |t|
                #{arrayified_params.map do |parameter|
                  <<-INNEREOF
                #{parameter}
                  INNEREOF
                  end.join("").strip}
                t.timestamps
              end
            end
          end
        EOF
      end
    end
  end
end
