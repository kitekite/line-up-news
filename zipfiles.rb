require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'zip/zip'
require 'redis'
require 'xml/to/json'
require File.join(File.dirname(__FILE__), 'newslist')


url = 'http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/'

News = NewsList.new

def findzips(url)
	ziplink = []
	n=0

	doc = Nokogiri::HTML(open(url))
	doc.traverse do |el|
    	[el[:src], el[:href]].grep(/\.(zip)$/i).map{|l| URI.join(url, l).to_s}.each do |link|
        	#p link
        	ziplink[n+=1] = link 
    	end
    end

	zipdownload(ziplink)
end

def zipdownload(ziplinks)
	tmpdir = File.join(Dir.pwd,'tmp')
	Dir.mkdir tmpdir unless File.exists? tmpdir

	if ziplinks.length != 0
		puts ziplinks.size
		#ziplinks.reject(&:nil?).map { |link|  File.open(File.basename(link),'wb'){|f| f << open(link).read}}
		ziplinks.reject(&:nil?).map { |link|  
			filename = File.basename(link)
			IO.copy_stream(open(link), File.join(tmpdir,filename))
			puts link+"  "+File.basename(link,File.extname(link))
		}
	end
end

def ziplist()
	Dir.glob("*/*.zip") do |filename|
		#p filename+" "+((File.join(Dir.pwd,filename)).to_s+" "+(File.basename(filename,File.extname(filename))).to_s)
		extractzip((File.join(Dir.pwd,filename)).to_s, (File.basename(filename,File.extname(filename))).to_s)
	end
	#if !filename.blank?

end

def extractzip(file_path, filename)
	Zip::ZipFile.open(file_path) do |zipfile|
		p filename+"  -- "+file_path
		xmlf = File.join('tmp',filename)
		#Dir.mkdir filename unless File.exists? filename
		Dir.mkdir xmlf unless File.exists? xmlf
		zipfile.each{|e|
			fpath = File.join(xmlf, e.name) 
			zipfile.extract(e, fpath){ true }
			#p e.name+"   "+(File.join(Dir.pwd,(File.join(xmlf,e.name)))).to_s
			readxml(File.join(Dir.pwd,(File.join(filename,e.name))).to_s){true}
		}
	end
end

def readxml(xmlfile)
	
	p "inside readxml"
	data = Nokogiri::XML(open(xmlfile))
	News.push(data)
		
end



begin
	findzips(url)
	ziplist()


rescue Exception => e
  	print e, "\n"
end





