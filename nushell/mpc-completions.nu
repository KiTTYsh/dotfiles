# mpc completions for nushell

def "nu-complete mpc playlists" [] {
  ^mpc lsplaylists | lines
}

def "nu-complete mpc outputs" [] {
  ^mpc outputs | lines | parse "Output {value} ({description}) is {status}"
}

def "nu-complete mpc uris" [context: string, position: int] {
  # Extract the partial URI, stripping "mpc <subcommand> " prefix and any quotes
  let partial = (
    $context
    | str substring ..$position
    | str replace -r '^\S+\s+\S+\s*' ''
    | str replace -a '"' ''
    | str replace -a "'" ''
    | str replace -a '`' ''
  )

  # Determine parent directory to list
  let dir = if ("/" in $partial) {
    if ($partial | str ends-with "/") {
      $partial | str trim -r -c "/"
    } else {
      $partial | path dirname
    }
  } else {
    ""
  }

  # Get directories at this level (to know which entries get a trailing /)
  let dirs = if $dir == "" {
    do { ^mpc lsdirs } | complete | get stdout | lines | where $it != ""
  } else {
    do { ^mpc lsdirs $dir } | complete | get stdout | lines | where $it != ""
  }

  # Get all entries at this level
  let entries = if $dir == "" {
    do { ^mpc ls } | complete | get stdout | lines | where $it != ""
  } else {
    do { ^mpc ls $dir } | complete | get stdout | lines | where $it != ""
  }

  # Build completions: directories get trailing /, values with special chars get backtick-quoted
  let completions = ($entries | each { |entry|
    let is_dir = ($entry in $dirs)
    let display = if $is_dir { $"($entry)/" } else { $entry }
    let value = if ($display =~ '[^a-zA-Z0-9/_.\-]') { $"`($display)`" } else { $display }
    { value: $value, description: (if $is_dir { "directory" } else { "" }) }
  })

  {
    options: {
      completion_algorithm: "prefix"
      sort: true
    }
    completions: $completions
  }
}

def "nu-complete mpc on-off" [] {
  [on off]
}

def "nu-complete mpc single-state" [] {
  [on once off]
}

def "nu-complete mpc replaygain-mode" [] {
  [off track album]
}

# Display mpc status
export extern "mpc" [
  -f, --format: string       # Print status with format
  -v, --verbose              # Give verbose output
  -q, --quiet                # Suppress status message
  -h, --host: string         # Connect to server on host
  -P, --password: string     # Connect to server using password
  -p, --port: int            # Connect to server port
]

# Add a song to the queue
export extern "mpc add" [
  uri: string@"nu-complete mpc uris"  # URI to add
]

# Add a song to a playlist
export extern "mpc addplaylist" [
  file: string               # Playlist name
  ...uris: string            # URIs to add
]

# Download album art for a song
export extern "mpc albumart" [
  uri: string                # Song URI
]

# Compact disk player-like previous command
export extern "mpc cdprev" []

# List channels other clients have subscribed to
export extern "mpc channels" []

# Clear the queue
export extern "mpc clear" []

# Clear the current error
export extern "mpc clearerror" []

# Clear a playlist
export extern "mpc clearplaylist" [
  file: string@"nu-complete mpc playlists"  # Playlist to clear
]

# Toggle consume mode, or specify state
export extern "mpc consume" [
  state?: string@"nu-complete mpc on-off"   # on or off
]

# Remove all but the currently playing song
export extern "mpc crop" []

# Set and display crossfade settings
export extern "mpc crossfade" [
  seconds?: int              # Crossfade duration in seconds
]

# Show the currently playing song
export extern "mpc current" [
  -f, --format: string       # Print with format
  -w, --wait                 # Wait for song change
]

# Remove a song from the queue
export extern "mpc del" [
  position: int              # Queue position to remove
]

# Delete partition(s)
export extern "mpc delpart" [
  ...names: string           # Partition names to delete
]

# Remove a song from a playlist
export extern "mpc delplaylist" [
  file: string@"nu-complete mpc playlists"  # Playlist name
  ...positions: int          # Positions to remove
]

# Disable output(s)
export extern "mpc disable" [
  ...outputs: string@"nu-complete mpc outputs"  # Output number or name
]

# Enable output(s)
export extern "mpc enable" [
  ...outputs: string@"nu-complete mpc outputs"  # Output number or name
]

# Find a song (exact match)
export extern "mpc find" [
  type: string               # Tag type
  query: string              # Query value
]

# Find songs and add them to the queue
export extern "mpc findadd" [
  type: string               # Tag type
  query: string              # Query value
]

# Idle until an event occurs
export extern "mpc idle" [
  ...events: string          # Events to wait for
]

# Continuously idle until an event occurs
export extern "mpc idleloop" [
  ...events: string          # Events to wait for
]

# Insert a song after the current track
export extern "mpc insert" [
  uri: string@"nu-complete mpc uris"  # URI to insert
]

# Show all tags of a type
export extern "mpc list" [
  type: string               # Tag type
  filter_type?: string       # Filter tag type
  filter_query?: string      # Filter query
]

# List all songs in the music dir
export extern "mpc listall" [
  file?: string              # Path filter
]

# List neighbors
export extern "mpc listneighbors" []

# Load a playlist into the queue
export extern "mpc load" [
  file: string@"nu-complete mpc playlists"  # Playlist to load
  -r, --range: string        # Range [start]:[end]
]

# List contents of a directory
export extern "mpc ls" [
  directory?: string         # Directory to list
]

# List subdirectories
export extern "mpc lsdirs" [
  directory?: string         # Directory to list
]

# List currently available playlists
export extern "mpc lsplaylists" []

# Create partition(s)
export extern "mpc makepart" [
  ...names: string           # Partition names to create
]

# Set and display mixrampdb settings
export extern "mpc mixrampdb" [
  db?: number                # dB value
]

# Set and display mixrampdelay settings
export extern "mpc mixrampdelay" [
  seconds?: number           # Delay in seconds
]

# List mounts or add a new mount
export extern "mpc mount" [
  mount_path?: string        # Mount path
  storage_uri?: string       # Storage URI
]

# Move song in queue
export extern "mpc move" [
  from: int                  # Source position
  to: int                    # Destination position
]

# Move output to partition (use -a for partition)
export extern "mpc moveoutput" [
  output: string@"nu-complete mpc outputs"  # Output number or name
]

# Move song in playlist
export extern "mpc moveplaylist" [
  file: string@"nu-complete mpc playlists"  # Playlist name
  from: int                  # Source position
  to: int                    # Destination position
]

# Play the next song in the queue
export extern "mpc next" []

# Show the current outputs
export extern "mpc outputs" []

# Set output attributes
export extern "mpc outputset" [
  output: string@"nu-complete mpc outputs"  # Output number or name
  ...attrs: string           # name=value attributes
]

# List partitions
export extern "mpc partitions" []

# Pause the currently playing song
export extern "mpc pause" []

# Pause if playing; exit with failure if not
export extern "mpc pause-if-playing" []

# Start playing at position
export extern "mpc play" [
  position?: int             # Queue position
]

# Print a playlist
export extern "mpc playlist" [
  playlist?: string@"nu-complete mpc playlists"  # Playlist name
  -f, --format: string       # Print with format
]

# Play the previous song in the queue
export extern "mpc prev" []

# Change song priorities in the queue
export extern "mpc prio" [
  prio: int                  # Priority value
  ...positions: string       # Position or range
]

# Show the next queued song
export extern "mpc queued" [
  -f, --format: string       # Print with format
]

# Toggle random mode, or specify state
export extern "mpc random" [
  state?: string@"nu-complete mpc on-off"   # on or off
]

# Download a picture from a song
export extern "mpc readpicture" [
  uri: string                # Song URI
]

# Rename a playlist
export extern "mpc renplaylist" [
  file: string@"nu-complete mpc playlists"  # Current name
  newfile: string            # New name
]

# Toggle repeat mode, or specify state
export extern "mpc repeat" [
  state?: string@"nu-complete mpc on-off"   # on or off
]

# Set or display the replay gain mode
export extern "mpc replaygain" [
  mode?: string@"nu-complete mpc replaygain-mode"  # off, track, or album
]

# Rescan music directory (including unchanged files)
export extern "mpc rescan" [
  path?: string              # Path to rescan
  -w, --wait                 # Wait for completion
]

# Remove a playlist
export extern "mpc rm" [
  file: string@"nu-complete mpc playlists"  # Playlist to remove
]

# Save the queue as a playlist
export extern "mpc save" [
  file: string               # Playlist name
]

# Search for a song
export extern "mpc search" [
  type: string               # Tag type
  query: string              # Query value
]

# Search songs and add them to the queue
export extern "mpc searchadd" [
  type: string               # Tag type
  query: string              # Query value
]

# Find and play a song in the queue
export extern "mpc searchplay" [
  pattern: string            # Search pattern
]

# Seek to a position
export extern "mpc seek" [
  position: string           # [+-][HH:MM:SS] or 0-100%
]

# Seek by an amount of time within song and playlist
export extern "mpc seekthrough" [
  position: string           # [+-][HH:MM:SS]
]

# Send a message to a channel
export extern "mpc sendmessage" [
  channel: string            # Channel name
  message: string            # Message to send
]

# Shuffle the queue
export extern "mpc shuffle" []

# Toggle single mode, or specify state
export extern "mpc single" [
  state?: string@"nu-complete mpc single-state"  # on, once, or off
]

# Display statistics about MPD
export extern "mpc stats" []

# Sticker management
export extern "mpc sticker" [
  uri: string                # Song URI
  command: string            # get, set, list, delete, or find
  ...args: string            # Additional arguments
]

# Stop playback
export extern "mpc stop" []

# Subscribe to a channel and continuously receive messages
export extern "mpc subscribe" [
  channel: string            # Channel name
]

# Toggle Play/Pause, plays if stopped
export extern "mpc toggle" []

# Toggle output(s)
export extern "mpc toggleoutput" [
  ...outputs: string@"nu-complete mpc outputs"  # Output number or name
]

# Remove a mount
export extern "mpc unmount" [
  mount_path: string         # Mount path to remove
]

# Scan music directory for updates
export extern "mpc update" [
  path?: string              # Path to update
  -w, --wait                 # Wait for completion
]

# Report version of MPD
export extern "mpc version" []

# Set volume or adjust by amount
export extern "mpc volume" [
  num: string                # [+-]num
]

# Wait for a message on a channel
export extern "mpc waitmessage" [
  channel: string            # Channel name
]
