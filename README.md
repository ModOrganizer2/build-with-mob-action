# Build with `mob` GitHub Action

Action to build ModOrganizer 2 components within GitHub workflows.

**Example usage**:

```yml
name: Build My Plugin
on:
  push:
    branches: [master]
  pull_request:
    types: [opened, synchronize, reopened]
jobs:
  build:
    runs-on: windows-2022
    steps:
      - name: Build My Plugin
        uses: ModOrganizer2/build-with-mob-action@master
        with:
          mo2-dependencies: uibase
```

The action must be run on `windows-2022` since MSVC is required.

## Configuration

The following options should be specified most of the time:

- `mo2-dependencies` - List of MO2 components to build before the current one.
  - `cmake_common` will always be included, whether you specify it or not,
  - these components will be built on a matching branch (when possible),
    e.g., if the current branch is `dev-branch`, components will be built on the
    `dev-branch` branch (if available) or `master` otherwise.
  - these builds are not cached between runs.

The following inputs are not mandatory but can be used to customize the build:

- `mo2-owner` - The Github organization to use to lookup dependencies, default to
  the current organization.
- `mo2-branch` - The branch to build, default to the current branch.
- `mo2-skip-checkout` - Skip checkout for the component (imply `mo2-skip-configure`
  and `mo2-skip-build`).
- `mo2-skip-configure` - Skip the CMake configure step for the component (not for
  dependencies), imply `mo2-skip-build`.
- `mo2-skip-build` - Skip the CMake build step for the component (not for dependencies).
- `qt-install` - Default is `'true'`, set to `'false'` to disable installing Qt (build
  will most likely fail unless Qt is installed before running this action).
- `qt-version` - Version of Qt to install. Default is to use the version defined by
  `mob.ini` in the `mob` repository.
- `qt-modules` - List of extra Qt modules to install.

The following outputs are available:

- `cmake-prefix-path` - Suitable value to set `CMAKE_PREFIX_PATH` to if configuring
  manually.
- `cmake-install-path` - Suitable value to set `CMAKE_INSTALL_PATH` to if configuring
  manually.
- `working-directory` - Directory where the component was checked out (if
  `mo2-skip-checkout` was not specified).
