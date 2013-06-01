require_relative "recall/version"
require "sinatra"
require "data_mapper"
require "haml"
require "sinatra/flash"
require "sinatra/redirect_with_flash"

enable :sessions # support for encrypted, cookie-based sessions

SITE_TITLE = "Recall"
SITE_DESCRIPTION = "'cause you're too busy to remember"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Note
	include DataMapper::Resource
	property :id, Serial # id field which will be an integer primary key and auto-incrementing
	property :content, Text, :required => true
	property :complete, Boolean, :required => true, :default => false
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade! # autmomatically update the database to contain the tables and fields
                                  # we've set, and to do so again if we make any changes to the schema
helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end

get '/' do
	@notes = Note.all :order => :id.desc # Retreive all the notes from the database. Using an @ instance variable here
	                                     # so that it wil be accessable from within the view file 
	@title = 'All Notes'
	if @notes.empty?
		flash.sweep[:notice] = 'No notes found. Add your first below.'
	end
	haml :home
end

post '/' do
	n = Note.new # create a new Note object in the notes table in the database
	n.content = params[:content] # The content field is set to the submitted data from the text area
	n.created_at = Time.now # current timestamp
	n.updated_at = Time.now # current timestamp
	if n.save
		redirect '/', :notice => 'Note created successfully.'
	else
		redirect '/', :error => 'Failed to save note.'
	end
end

get '/rss.xml' do
	@notes = Note.all :order => :id.desc
	builder :rss
end

get '/:id' do
    Note.get params[:id]
		@note = Note.get params[:id] # Retrieve the requested note from the database using the ID provided
		@title = "Edit note ##{params[:id]}" # Set up a @title variable
		if @note
  		haml :edit # Load the views/edit.erb view file through the ERB parser (soon to be haml parser ;)
  	else
  		redirect '/', :error => "Can't find that note."
  	end
end

put '/:id' do
	n = Note.get params[:id]
	n.content = params[:content]
	n.complete = params[:complete] ? 1 : 0 # Using the ternary operator to set n.complete to 1 if the params[:complete] exists,
	                                       # or 0 otherwise. The value of a checkbox is only submitted with a form if it is checked,
	                                       # so we're simply checking for the existence of it.
	n.updated_at = Time.now
	if n.save
		redirect '/', :notice => "Note updated successfully."
	else
		redirect '/', :error => 'Error updating note.'
	end
end

get '/:id/delete' do
	@note = Note.get params[:id]
	@title = "Confirm deletion of note ##{params[:id]}"
	if @note
		haml :delete
	else
		redirect '/', :error => "Can't find that note."
	end
end

delete '/:id' do
	n = Note.get params[:id]
	if n.destroy
		redirect '/', :notice => 'Note deleted successfully.'
	else
		redirect '/', :error => 'Error deleting note.'
	end
end

get '/:id/complete' do
	n = Note.get params[:id]
	n.complete = n.complete ? 0 : 1 # flip it - if complete set incomplete and vice versa
	n.updated_at = Time.now
	if n.save
		redirect '/', :notice => "Note marked as complete."
	else
		redirect '/', :error => "Error marking note as complete."
	end
end
