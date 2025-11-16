function git-push {
    if [[ "$1" == "" ]]; then
        echo "Usage: git-push <commit-message> <branch-name>"
        return 1
    fi
    git add --all
    git commit -m "$1"
    if [[ "$2" != "" ]]; then
        git push --set-upstream origin "$2"
    else
        git push
    fi
}

function note {
    if [[ -z "$1" ]]; then
        echo "Usage: note <text>"
        return 1
    fi
    dir="$DOTFILES/notes"
    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d).md"
    time="$(date +%H:%M)"
    {
        echo -e "### $HOST ### $(pwd) ### $time ###\n"
        for arg in "$@"; do
            echo "$arg"
        done
        echo ""
    } >> "$file"
    echo "Note added to $file"
}