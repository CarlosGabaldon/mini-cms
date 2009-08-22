require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'rexml/document'
require 'uri'

class Media
  attr_accessor :id, :title, :desc, :elements
  
end

module Cache
  class Store
    class << self
      def put(url, value)
        file = "cache/#{keyify(url)}"
        File.open(file, 'w') do |f|
          f.write(value)
        end
      end
      
      def get(url)
        cache = ""
        file = "cache/#{keyify(url)}"
        return "" unless File.exist? file
        File.open(file, 'r') do |f|
          cache = f.read
        end
      end
      
      def keyify(url)
        uri = URI.parse(url)
        "#{uri.host}#{uri.path.tr('/', '_')}"
      end
    end
  end
end


get '/folder/:id' do |folder_id|
  
  
  @url = "http://vcms.nbcuni.ge.com/videocms/rest/content/listClipByFolder.do?folderID=#{folder_id}"
  @nocache = 'true'
  @media_list = []
  
  #1 Fetch content from cache
   @xml = Cache::Store.get(@url) unless @nocache == "true"
  
  if @xml == nil || @xml == ""
     open(@url) do |file|
      @xml = file.read
      Cache::Store.put(@url, @xml)
     end
   end   
     
   doc = REXML::Document.new(@xml)
     
   doc.elements.each('clipMetadataList/clipMetadata') do |c|
     
      media = Media.new
      media.id = c.elements['metadataProfileId'].text
      media.title = c.elements['title'].text
      media.desc = c.elements['shortDesc'].text
      media.elements = c.elements
      @media_list <<  media
      
   end
   
   erb :list
  
end

get '/view/:id' do |id|
  @id = id
  erb :view
  
end