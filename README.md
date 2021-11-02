# Shell completions for Julia

This repository provides shell tab completions for the [Julia programming language](https://julialang.org/).
Currently the only supported shell is Bash -- contributions for other shells are welcome.

## Installation

1. Download the script:
   ```
   mkdir -p ~/.bash_completion.d
   curl -fsSL -o ~/.bash_completion.d/julia-completion.bash \
        https://raw.githubusercontent.com/fredrikekre/julia-completions/master/julia-completion.bash
   ```
2. Hook into the shell:
   ```
   echo '# Bash completion for julia, see https://github.com/fredrikekre/julia-completions
   if [[ -f ~/.bash_completion.d/julia-completion.bash ]]; then
       . ~/.bash_completion.d/julia-completion.bash
   fi' >> ~/.bashrc
   ```
