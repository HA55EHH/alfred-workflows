# Alfred Workflows

A collection of Alfred workflows that I have made. Check the `README.md` in each
directory for more information, or to install, download and open the `.alfredworkflow`
file.

## Developer Instructions

If you wish to contribute to one of the workflows, be sure to remove any existing
installations from Alfred. Then clone this repository and run `install.py ./WorkflowDir`
in the scripts directory. This will create a symbolic link between the workflow folder
in this repository and the Alfred workflows directory. Any changes made in Alfred or in
the repo will be reflected in both locations. This script uses all standard library
packages, so a clean version of Python (such as the one that comes with MacOS) should
work fine.

When you are ready to release a change, run `./scripts/release.sh`. This will take the
contents of the readme in `info.plist` and copy it to the workflow directory, prompt for
a version update and create the `.alfredworkflow` file.
