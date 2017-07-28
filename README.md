# sh-composer-wrapper

Shell scripts that wraps Composer - a Dependency Manager for PHP.

## Features

The basic `composer` script does little more than run Composer without
the Xdebug extension loaded. It also looks for more wrapper scripts.

Those include:

### `git-backup.sh`

When you update or install packages with Composer, this script finds
all Git repositories in the vendor directory that still contain
uncommitted or unpushed changes and creates a backup for them. The backup
will be placed in `$HOME/.cache/sh-composer-wrapper` and will be created
via `git bundle create`. It will also backup the root repository.
