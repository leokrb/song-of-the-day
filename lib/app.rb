# frozen_string_literal: true

require 'date'
require 'json'
require 'open-uri'
require 'dotenv/load'

KEY = ENV['API_KEY']
ROOT_URL = 'http://ws.audioscrobbler.com/2.0/'

puts 'What\'s your username?'
USER = gets.chomp

puts 'How far do you want to go back? Please type in a year.'
YEAR = gets.chomp.to_i

def create_timestamps_from(date)
  last_year = date.prev_year
  last_year_ending = last_year + 1
  beginning_timestamp = last_year.strftime('%s')
  ending_timestamp = last_year_ending.strftime('%s')
  puts "#{last_year.year}..."
  [beginning_timestamp, ending_timestamp]
end

def fetch_tracks_for(time)
  url = "#{ROOT_URL}?method=user.getrecenttracks&user=#{USER}&api_key=#{KEY}&from=#{time[0]}&to=#{time[1]}&format=json"
  json_output = JSON.parse(open(url).read)
  json_output['recenttracks']['track']
end

def fetch_all_songs_from_past_date(songs)
  songs_array = []
  songs.each do |song|
    song_title = song['name']
    song_artist = song['artist']['#text']
    songs_array << "#{song_title} by #{song_artist}"
  end
  songs_array.uniq
end

def calculate_year_for_results_hash(timestamps)
  timestamp_integer = timestamps[0].to_i
  Time.at(timestamp_integer).to_datetime.year
end

def collect_all_tracks
  today = Date.today
  results_hash = {}
  puts 'Traveling back in time...'

  while today.year > YEAR
    timestamps = create_timestamps_from(today)
    json = fetch_tracks_for(timestamps)
    if json != []
      array_of_songs = fetch_all_songs_from_past_date(json)
      year = calculate_year_for_results_hash(timestamps)
      results_hash[year] = array_of_songs
    end

    today = today.prev_year
  end
  results_hash
end

def output
  results = collect_all_tracks
  if results != {}
    random_song = results.values.sample
    puts "On this day in #{results.key(random_song)} you played #{random_song.sample}"
  else
    puts "You've never played a song on this date. Sad!"
  end
end

output
