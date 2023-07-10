# Build with `mob` Github Action

Action to build ModOrganizer 2 components within Github workflows.

**Example usage**:

```yml
name: Build UI Base
on:
  push:
    branches: master
  pull_request:
    types: [opened, synchronize, reopened]
jobs:
  build:
    runs-on: windows-2022
    steps:
      - name: Build UI Base
        uses: ModOrganizer2/build-with-mob-action@master
        with:
          mo2-third-parties: fmt gtest spdlog boost
          mo2-dependencies: cmake_common

```

The action must be run on `windows-2022` since MSVC is required.

## Configuration

The following options should be specified most of the time:

- `mo2-third-parties` - List of project to build with `mob` before any `super` task,
  e.g., `fmt`, `spdlog`, `boost`, `pybind11`, etc.
  - these dependencies are cached between runs depending on the latest release of `mob`.
- `mo2-dependencies` - List of MO2 components to build before the current one.
  - these components will be built using `mob` and the current branch (when possible),
    e.g., if the current branch is `dev-branch`, components will be built on the
    `dev-branch` branch (if available) or `master` otherwise.
  - these builds are not cached between runs.

The following options are not mandatory but can be used to customize the build:

- `mo2-branch` - The branch to build, default to the current branch.
- `mo2-cmake-command` - The CMake command to run with `mob cmake`, default to `..`
  (same as `mob`).
- `qt-install` - Default is `'true'`, set to `'false'` to disable installing Qt (build
  will most likely fail unless Qt is installed before running this action).
- `qt-version` - Version of Qt to install. Default is to use the version defined by
  `mob.ini` in the `mob` repository.
- `qt-modules` - List of extra Qt modules to install.
