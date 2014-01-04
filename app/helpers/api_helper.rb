require 'httparty'

module ApiHelper
  include HTTParty
  base_uri('http://api.nfldata.apiphany.com/trial/JSON/')

  def api_init
    #@api_key = '2C057E71-1881-4F05-AE33-016AB738B116'
    #@api_key = '843FF8C4-A9F2-4220-97B4-3AED45A33300'
    @api_key = 'C2D37843-334D-4298-A10E-FB1485AAAB4E'

    @base_folder = File.join(Rails.root, 'lib', 'json_data')
    @my_folder = ''
  end

  def set_my_folder(folder)
    @my_folder = folder
  end

  def load_json_data(url, cache_file, cache_seconds = 0)
    cache_fullpath = File.join(@base_folder, @my_folder, cache_file)
    FileUtils.mkpath(File.dirname(cache_fullpath))
    use_cache = false

    if(File.exists?(cache_fullpath))
      if(cache_seconds > 0)
        cache_age = Time.now - File.stat(cache_fullpath).mtime
        use_cache = (cache_age <= cache_seconds)
      else
        use_cache = true
      end
    end

    if(use_cache)
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
    options = { query: { key: @api_key} }
    response = ApiHelper.get(url, options)
    response.body if response.code == 200
  end
end
