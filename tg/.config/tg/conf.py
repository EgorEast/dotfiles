import os

ENV_PATH = os.path.expanduser("~/.config/tg/.env")


def load_env(path):
    """Reads an env file into a dictionary."""
    env_vars = {}
    if os.path.exists(path):
        with open(path, "r") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, value = line.split("=", 1)
                    env_vars[key.strip()] = value.strip()
    return env_vars


def save_env_var(path, key, value):
    """Adds or updates a variable in the env file."""
    env_vars = load_env(path)
    env_vars[key] = value
    with open(path, "w") as f:
        for k, v in env_vars.items():
            f.write(f"{k}={v}\n")


# Load environment variables from file
env = load_env(ENV_PATH)
PHONE = env.get("PHONE")

# If PHONE is missing — ask the user and save it
if not PHONE:
    PHONE = input("Enter your Telegram phone number: ").strip()
    save_env_var(ENV_PATH, "PHONE", PHONE)

# PHONE is now ready to be used in the config
print(f"Using phone number: {PHONE}")

# # You can write anything you want here, file will be executed at start time
# # You can keep you sensitive information in password managers or gpg
# # encrypted files for example
# def get_pass(key):
#     # retrieves key from password store
#     return os.popen("pass show {} | head -n 1".format(key)).read().strip()
#
#
# PHONE = get_pass("i/telegram-phone")
# # encrypt you local tdlib database with the key
# ENC_KEY = get_pass("i/telegram-enc-key")

# # log level for debugging, info by default
# LOG_LEVEL = "DEBUG"
# # path where logs will be stored (all.log and error.log)
# LOG_PATH = os.path.expanduser("~/.local/share/tg/")
#
# # If you have problems with tdlib shipped with the client, you can install and
# # use your own, for example:
# TDLIB_PATH = "/usr/local/Cellar/tdlib/1.6.0/lib/libtdjson.dylib"
#
# # you can use any other notification cmd, it is simple python string which
# # can format title, msg, subtitle and icon_path paramters
# # In these exapmle, kitty terminal is used and when notification is pressed
# # it will focus on the tab of running tg
# NOTIFY_CMD = "/usr/local/bin/terminal-notifier -title {title} -subtitle {subtitle} -message {msg} -appIcon {icon_path} -sound default -execute '/Applications/kitty.app/Contents/MacOS/kitty @ --to unix:/tmp/kitty focus-tab --no-response -m title:tg'"
#
# # You can use your own voice recording cmd but it's better to use default one.
# # The voice note must be encoded with the Opus codec, and stored inside an OGG
# # container. Voice notes can have only a single audio channel.
# VOICE_RECORD_CMD = "ffmpeg -f avfoundation -i ':0' -c:a libopus -b:a 32k {file_path}"
#
# # You can customize chat and msg flags however you want.
# # By default words will be used for readability, but you can make
# # it as simple as one letter flags like in mutt or add emojies
# CHAT_FLAGS = {
#     "online": "●",
#     "pinned": "P",
#     "muted": "M",
#     # chat is marked as unread
#     "unread": "U",
#     # last msg haven't been seen by recipient
#     "unseen": "✓",
#     "secret": "🔒",
#     "seen": "✓✓",  # leave empty if you don't want to see it
# }
# MSG_FLAGS = {
#     "selected": "*",
#     "forwarded": "F",
#     "new": "N",
#     "unseen": "U",
#     "edited": "E",
#     "pending": "...",
#     "failed": "💩",
#     "seen": "✓✓",  # leave empty if you don't want to see it
# }
#
# # use this app to open url when there are multiple
# URL_VIEW = "urlview"
#
# # Specifies range of colors to use for drawing users with
# # different colors
# # this one uses base 16 colors which should look good by default
# USERS_COLORS = tuple(range(2, 16))
#
# # to use 256 colors, set range appropriately
# # though 233 looks better, because last colors are black and gray
# # USERS_COLORS = tuple(range(233))
#
# # to make one color for all users
# # USERS_COLORS = (4,)
#
# # cleanup cache
# # Values: N days, None (never)
# KEEP_MEDIA = 7
#
# FILE_PICKER_CMD = "ranger --choosefile={file_path}"
# # FILE_PICKER_CMD = "nnn -p {file_path}"
#
# MAILCAP_FILE = os.path.expanduser("~/.config/mailcap")
#
# DOWNLOAD_DIR = os.path.expanduser("~/Downloads/")  # copy file to this dir
