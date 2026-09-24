#!/usr/bin/env bash

export FZF_COMPLETION_TRIGGER=','


eval "$(mise activate bash)"
eval $(gh completion -s bash)
eval "$(peanutbutter completions bash)"
eval "$(fzf --bash)"
