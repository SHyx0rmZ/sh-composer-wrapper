git_backup() {
  local CURRENT_DIR="$(pwd)"

  echo "\033[0;32mBacking up unsaved work\033[0m"

  git_backup_repository "."

  if [ ! -f composer.json ]; then
    if [ "$(git rev-parse --show-toplevel 2> /dev/null)" != "" ]; then
      cd "$(git rev-parse --show-toplevel)"
    fi
  fi

  if [ -f composer.json ]; then
    for dependency in $($(php_composer) show | awk '{print $1}'); do
      if [ -d "${PWD}/vendor/${dependency}/.git" ]; then
        git_backup_repository "${PWD}/vendor/${dependency}"
      fi
    done
  fi
}

git_backup_cache_dir() {
  echo "${HOME}/.cache/sh-composer-wrapper"
}

git_backup_repository() {
  cd "$1"

  if [ "$(git rev-parse --show-toplevel 2> /dev/null)" = "" ]; then
    # not a Git repository
    return
  fi

  if [ "$(git rev-parse --all)" = "" ]; then
    # Git repository does not contain any refs
    return
  fi

  if [ "$(git status --porcelain)" = "" ] && \
     [ "$(git log --branches --not --remotes)" = "" ] && \
     [ "$(git stash list)" = "" ]; then
    # Git repository does not contain any changes
    return
  fi

  local REPONAME="$(echo "$(git rev-parse --show-toplevel | xargs dirname | xargs basename)/$(git rev-parse --show-toplevel | xargs basename)")"

  echo "  - Backing up Git repository to \033[32m$(git_backup_target "${1}" "${REPONAME}")\033[0m (\033[0;33m$(echo "$1" | sed 's@.*/vendor/@@')\033[0m)"

  git bundle create "$(git_backup_target "${1}" "${REPONAME}")" --all 2> /dev/null
}

git_backup_target() {
  if [ "$1" = "." ]; then
    local PARENT=""
    local CHILD="$(basename "$2")"
  else
    local PARENT="/$(echo "$1" | sed 's@/vendor/.*@@' | xargs basename)/$(dirname "$2" | xargs basename)"
    local CHILD="$(basename "$2")"
  fi

  mkdir -p "$(git_backup_cache_dir)${PARENT}"

  echo "$(git_backup_cache_dir)${PARENT}/${CHILD}.git"
}

case "$1" in
  install|update)
    git_backup
    ;;

  *)
    # safe operation, do nothing
    ;;
esac
