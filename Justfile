mod server
mod client 'client-web'

default:
  @just --list

setup:
  python3 scripts/setup_dev_db.py

skir-gen:
  bunx skir@1.2 gen

skir-format:
  bunx skir@1.2 format

skir-format-check:
  bunx skir@1.2 format --ci

skir-snapshot:
  bunx skir@1.2 snapshot

skir-snapshot-check:
  bunx skir@1.2 snapshot --ci

test:
  just server::test
  just client::test

check:
  just devcontainer-shellcheck
  just skir-format-check
  just skir-snapshot-check
  just server::format-check
  just server::check
  just server::lint
  just server::test
  just client::format-check
  just client::type-check
  just client::lint
  just client::deadcode
  just client::test

fix-format:
  just skir-format
  just server::format
  just client::format

fix-all:
  just fix-format
  just client::lint-fix

devcontainer-shellcheck:
  find .devcontainer -type f -name '*.sh' -print0 | xargs -0r shellcheck
