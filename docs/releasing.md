# Release distribution

Review and merge ordinary PRs, including Dependabot and these workflow changes,
after their checks pass. No ordinary merge creates an upstream release.

For fv-ssh-unlock, choose a version using Prepare tagged release in the source
repository after main CI passes. **Sync fv-ssh-unlock release** checks hourly
(minute 37), or run it immediately on this repository's main with an explicit
published tag. It verifies both upstream publishers, source identity, signed
checksums, downloaded payloads and the signed multi-platform container before
opening a version-only manifest PR. It does not write this repository's main.

`.github/fv-release-channel.json` defaults to `preview` to continue the current
release-candidate feed. Preview includes stable releases. Change to `stable`
through a configuration PR to exclude future prereleases. Version comparison
prevents any downgrade, including an older stable version replacing a newer RC.

## Approve distribution

Review and merge the generated manifest PR after **Validate bucket** succeeds on
its current head. It checks both Windows archive hashes/layout and executes the
AMD64 binary's version command. ARM64 execution is not claimed. The workflow
explicitly dispatches read-only validation for generated branches; GitHub may
also ask you to **Approve workflows to run** on a bot-created PR.

After your merge, **Feed installation smoke test** installs fv-ssh-unlock through
an actual fresh Scoop installation and the public bucket, then checks the version
and CLI. No separate Scoop publishing step is required. The source repository's
Release distribution status issue closes after both package feeds and their
current-main installation tests pass.

Existing daily stable updates for Audio Fade Fixer and Takeout Helper now stage
manifest changes, validate them, verify downloaded release bytes, and create
reviewable PRs instead of directly pushing main. fv-ssh-unlock is handled only by
the verified stable/preview sync to avoid competing writers. No new personal or
cross-repository token is needed; the shared action is pinned to a reviewed SHA.

## Setup and recovery

Merge the source release-tools PR first, then this workflow PR. An administrator
may need to enable Actions' **Allow GitHub Actions to create and approve pull
requests** setting. The workflows never approve reviews or modify settings.
Bot-created PR workflow approval can remain manual. Hourly schedules are best
effort; the manual Sync action is available for immediate updates and retries.

Sync refuses changed generated branches rather than discarding your edits. It
can refresh unedited generated PRs against new main, followed by fresh tests.
Closed PR decisions are not automatically overridden. Already-current versions
are no-ops. Rerun read-only validation/install checks as needed, not a successful
upstream publisher. No tag or existing release asset is changed by this setup.
