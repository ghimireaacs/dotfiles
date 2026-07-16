# Apple Silicon: /opt/homebrew not in PATH by default
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Ensure true color support — fastfetch and other tools read this
export COLORTERM=truecolor
