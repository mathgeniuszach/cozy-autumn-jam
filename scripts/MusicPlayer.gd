extends AudioStreamPlayer

const FADEOUT_SECONDS = 0.5

var songs: Dictionary = {
	"calm": preload("res://assets/music/calm.ogg"),
	"spicy_intro": preload("res://assets/music/spicy_intro.ogg"),
	"spicy_loop": preload("res://assets/music/spicy_loop.ogg")
}

var song = null
var next_song = null
var changing = false

func set_fadeout(f):
	fadeout = f
	if fadeout < 0: fadeout = 0
	volume_db = linear2db(fadeout*volume)
var fadeout = 1 setget set_fadeout

func set_volume(v):
	volume = v
	volume_db = linear2db(fadeout*volume)
var volume = 0.5 setget set_volume

func play_song_now(s):
	if s != null:
		assert(songs.has(s), 'Invalid song "%s"' % s)
		stream = songs[s]
		play()
	
	song = s

func queue_song(s):
	if s != song:
		changing = true
		next_song = s

func _process(delta):
	if changing:
		if song == null:
			if next_song: play_song_now(next_song)
			changing = false
		else:
			if not playing or self.fadeout <= 0:
				song = null
				stop()
				self.fadeout = 1
			else:
				self.fadeout -= delta / FADEOUT_SECONDS
	else:
		if not playing:
			if song == "spicy_intro":
				play_song_now("spicy_loop")

