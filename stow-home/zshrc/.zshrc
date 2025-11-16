export PATH=$HOME/.local/bin:$PATH:/usr/local/go/bin

for file in $HOME/.config/zsh/*.zsh ; do
    source "$file"
done

clear && fastfetch
