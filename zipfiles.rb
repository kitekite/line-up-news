require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'zip/zip'
require 'redis'
require 'xml/to/json'
require File.join(File.dirname(__FILE__), 'newslist')


url = 'http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/'
thread_count = 10

News = NewsList.new


def findzips(url,thread_count)
	ziplink = []
	n=0

	doc = Nokogiri::HTML(open(url))
	doc.traverse do |el|
    	[el[:src], el[:href]].grep(/\.(zip)$/i).map{|l| URI.join(url, l).to_s}.each do |link|
        	ziplink[n+=1] = link 
    	end
    end
    if ziplink.length != 0
		zipdownload(ziplink,thread_count)
	end
end


def zipdownload(ziplinks,thread_count)
	#Thread.abort_on_exception = true

	tmpdir = File.join(Dir.pwd,'tmp')
	Dir.mkdir tmpdir unless File.exists? tmpdir

	queue = Queue.new
	ziplinks.reject(&:nil?).map {|zlink| queue << zlink}

	threads = thread_count.times.map do
		Thread.new do
			begin
				#p "inside thread "
				while !queue.empty? && zlink = queue.pop
					filename = File.basename(zlink)
					IO.copy_stream(open(zlink), File.join(tmpdir,filename))
					sleep 30
					#puts zlink+"  "+File.basename(zlink,File.extname(zlink))
				end
			rescue ThreadError
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
		#p filename+"  -- "+file_path
		xmlf = File.join('tmp',filename)
		Dir.mkdir xmlf unless File.exists? xmlf
		zipfile.each{|e|
			fpath = File.join(xmlf, e.name) #e.to_s
			#the block is for handling an existing file. returning true will overwrite the files.
			zipfile.extract(e, fpath){ true }
		}
	end
	
end

def readxml()
	Dir.glob("tmp/*/*.xml") do |xmlfile|
		#p "inside readxml"+xmlfile
		data = Nokogiri::XML(open(xmlfile))
		News.push(data)
	end
		
end



begin
	
	Thread.abort_on_exception = true
	p "Process running ..."
	bigthreads = []
	bigthreads << Thread.new{
		findzips(url,thread_count)
	}
	sleep 120
	bigthreads << Thread.new{
		100.times {
			ziplist()
		}
	}
	sleep 90
	bigthreads << Thread.new{
		500.times {
			readxml()
		}
	}

	sleep 60
	
	bigthreads.each(&:join)

rescue Exception => e
  	print e, "\n"
end
