require 'json'
require 'fileutils'

class SnapshotStorage
  SNAPSHOT_DIR = 'snapshots'

  def initialize(user_id)
    @user_id = user_id
    @user_dir = File.join(SNAPSHOT_DIR, user_id)
    FileUtils.mkdir_p(@user_dir)
  end
  
  def initialized?(playlist_id)
    File.exist?(snapshot_path(playlist_id))
  end
  
  def snapshot_path(playlist_id)
    File.join(@user_dir, "#{playlist_id}.json")
  end

  def save(playlist_id, tracks)
    File.write(snapshot_path(playlist_id), JSON.pretty_generate(tracks))
  end

  def load(playlist_id)
    path = snapshot_path(playlist_id)
    return [] unless File.exist?(path)

    JSON.parse(File.read(path))
  rescue JSON::ParserError
    []
  end
end
