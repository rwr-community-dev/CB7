import sys
import webbrowser
import urllib.parse
import pathlib

SCRIPT_DIR = pathlib.Path(__file__).parent
RWR_STEAM_URI = "steam://rungameid/270150//"
PKG_PATH = "media/packages/CB7"
VANILLA_MAPS_PATH_PREFIX = "media/packages/vanilla/maps/"

if __name__ == '__main__':
    map_id = sys.argv[1] if len(sys.argv) == 2 else "lobby"
    map_dir = SCRIPT_DIR / f"../vanilla/maps/{map_id}"
    map_id = map_id if map_dir.exists() else "lobby"

    rwr_cmd = [f"package={PKG_PATH}", f"map=media/packages/vanilla/maps/{map_id}",
               "verbose", "debugmode", "metagame_debugmode", "big_water"]
    webbrowser.open_new(f"{RWR_STEAM_URI}{'%20'.join(urllib.parse.quote(c, safe='') for c in rwr_cmd)}")

