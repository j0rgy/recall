require_relative '../lib/recall.rb'
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class RecallTest < Test::Unit::TestCase
	include Rack::Test::Methods

	def app
		Sinatra::Application
	end

	DataMapper.auto_migrate! # Clean test database before running each test

	def assert_response(resp, contains=nil, matches=nil, headers=nil, status=200)
		assert_equal(resp.status, status, "Expected response #{status} not in #{resp}")

		if status == 200
			assert(resp.body, "Response data is empty.")
		end

		if contains
			assert((resp.body.include? contains), "Response does not contain #{contains}")
		end

		if matches
			reg = Regexp.new(matches)
			assert reg.match(contains), "Response does not match #{matches}"
		end

		if headers
			assert_equal(resp.headers, headers)
		end
	end

	def test_index
		# test the homepage works
		get("/")
		assert last_response.ok?

		# test posting a new note 
		post "/", :content => "This is a test note."
		follow_redirect!
		assert last_response.ok?
	end

	def test_viewing_note
		# check that a non-existent note returns "Note not found"
		get("/foo")
		assert_response(last_response, "Note not found")

		# test viewing a note
		get("/1") # why does this work? Shouldn't there be no note #1? Didn't I delete it? Aren't tests ran in reverse?
		assert_response(last_response, "Edit")
		assert last_response.ok?
	end

	#def test_editing_note
		# test editing a note
	#	post "/", :content => "This is a new note"
	#	put "/2", :content => "This note has been edited."
	# follow_redirect!
  #  get "/2"
	#	assert_response(last_response, "This note has been edited")

		# test marketing a note as complete from the edit screen -- not sure how to do this yet
		# I don't know how to access database objects from the test file
		#put "/1", :complete => 1
		#follow_redirect!
		#puts last_response.body
		#@note = Note.get 1
		#puts @note
		#assert @note.complete
	#end

	def test_posting_deleting_note

    # Test posting a note
		post "/", :content => "This note will be deleted."
#    follow_redirect!
    
    # Test flash message displays
 #   assert_response(last_response, "Note created successfully.")

		get "/1"
		assert_response(last_response, "Edit")
		get "/1/delete"
		assert_response(last_response, "Confirm deletion of note #1")
		delete "/1"
		get "/1"
		assert_response(last_response, "Note not found")
	end

end