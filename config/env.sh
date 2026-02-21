export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/usr/local/bin
export TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../tools" && pwd)"
export PATH=$PATH:$TOOLS_DIR
