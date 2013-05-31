xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title SITE_TITLE
    xml.description SITE_DESCRIPTION
    xml.link request.url.chomp request.path_info  # Getting the current URL from the request object and "chomp"ing off the path to get the root domain
    
    @notes.each do |note| # For each note
      xml.item do # Create an XMl item
      	xml.title h note.content # The h escapes html
      	xml.link "#{request.url.chomp request.path_info}/#{note.id}"
      	xml.guid "#{request.url.chomp request.path_info}/#{note.id}"
      	xml.pubDate Time.parse(note.created_at.to_s).rfc822 # Converting the note's created_at time to RFC822, the required format for times in RSS
      	xml.description h note.content
      end 
    end
  end
end
