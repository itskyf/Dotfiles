if status is-interactive
	mise activate fish | source

	set --export EDITOR nvim
	set --export GPG_TTY (tty)

	set --export PNPM_HOME ~/Library/pnpm
else
	mise activate fish --shims | source
end


# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
