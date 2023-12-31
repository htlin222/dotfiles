
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /Users/htlin/opt/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<


# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
set -gx MAMBA_EXE "/Users/htlin/.micromamba/bin/micromamba"
set -gx MAMBA_ROOT_PREFIX "/Users/htlin/micromamba"
$MAMBA_EXE shell hook --shell fish --prefix $MAMBA_ROOT_PREFIX | source
# <<< mamba initialize <<<
