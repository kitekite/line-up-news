require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'zip/zip'
require 'redis'
require 'xml/to/json'
require File.join(File.dirname(__FILE__), 'newslist')


url = 'http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/'
thread_count = 25
News = NewsList.new

def findzips(url,thread_count)
	ziplink = []
	n=0

	doc = Nokogiri::HTML(open(url))
	doc.traverse do |el|
    	[el[:src], el[:href]].grep(/\.(zip)$/i).map{|l| URI.join(url, l).to_s}.each do |link|
        	#p link
        	ziplink[n+=1] = link 
    	end
    end
    if ziplink.length != 0
		zipdownload(ziplink,thread_count)
	end
	
end

def zipdownload(ziplinks,thread_count)
	Thread.abort_on_exception = true
	
	tmpdir = File.join(Dir.pwd,'tmp')
	Dir.mkdir tmpdir unless File.exists? tmpdir
	queue = Queue.new
	ziplinks.reject(&:nil?).map {|zlink| queue << zlink}

	threads = thread_count.times.map do
		Thread.new do
			#p "inside thread "
			while !queue.empty? && zlink = queue.pop
				filename = File.basename(zlink)
				IO.copy_stream(open(zlink), File.join(tmpdir,filename))
				#puts zlink+"  "+File.basename(zlink,File.extname(zlink))
			end
		end
	end

	threads.each(&:join)
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





