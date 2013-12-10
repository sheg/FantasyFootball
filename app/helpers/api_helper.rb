require 'httparty'

module ApiHelper
  include HTTParty

  $api_key = 'EE80A3DB-D928-4AFB-9931-57BB7B7892FE'
  base_uri('http://api.nfldata.apiphany.com/trial/JSON/')

  $base_folder = File.join(Rails.root, 'lib', 'json_data')
  $my_folder = ''

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def set_my_folder(folder)
      $my_folder = folder
    end
  end

  def load_json_data(url, cache_file)
    cache_fullpath = File.join($base_folder, $my_folder, cache_file)
    FileUtils.mkpath(File.dirname(cache_fullpath))

    if(File.exists?(cache_fullpath))
      puts "Using cache file #{cache_fullpath}"
      ret = JSON.parse(File.open(cache_fullpath).read)
    else
      puts "Pulling from API #{url}"
      json = load_from_api(url)

      if(json != nil)
        begin
          ret = JSON.parse(json)
        rescue
          # When json has been returned but cannot be parsed, it is a single value
          #   i.e. season is returned simply as "2013" so wrap it in mock JSON object
          ret = JSON.parse('{ "data": "' + json + '" }')
        end

        File.write(cache_fullpath, JSON.pretty_generate(ret)) if ret != nil
        puts "Saved cache file #{cache_fullpath}"
      else
        puts 'No response from API'
      end
    end

    ret
  end

  def load_from_api(url)
    options = { query: { key: $api_key } }
    response = self.class.get(url, options)
    response.body if response.code == 200
  end
end
