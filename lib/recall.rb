require_relative "recall/version"
require "sinatra"
require "data_mapper"

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

get '/' do
	@notes = Note.all :order => :id.desc # Retreive all the notes from the database. Using an @ instance variable here
	                                     # so that it wil be accessable from within the view file 
	@title = 'All Notes'
	erb :home
end

post '/' do
	n = Note.new # create a new Note object in the notes table in the database
	n.content = params[:content] # The content field is set to the submitted data from the text area
	n.created_at = Time.now # current timestamp
	n.updated_at = Time.now # current timestamp
	n.save
	redirect '/'
end


