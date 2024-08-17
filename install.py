#!/usr/bin/python3
import argparse
import json
import logging
import os
import plistlib
import shutil

ALFRED_PREFS = os.path.expanduser("~/Library/Application Support/Alfred/prefs.json")
DEFAULT_DIR = os.path.expanduser("~/Library/Appplication Support/Alfred")


def printable_path(dirpath):
    """Replace $HOME with ~."""
    return dirpath.replace(os.getenv("HOME"), "~")


def install_workflow(workflow_dir, install_base, symlink=False):
    """Install or symlink workflow at `workflow_dir` under `install_base`."""

    action = "Linking" if symlink else "Installing"
    logging.debug(f"{action} workflow at {workflow_dir!r} to {install_base!r}")

    infopath = os.path.join(workflow_dir, "info.plist")
    if not os.path.exists(infopath):
        logging.error(f"info.plist not found: {infopath}")
        return False

    with open(infopath, "rb") as fp:
        info = plistlib.load(fp)

    name = info.get("name")
    bundleid = info.get("bundleid")

    if not bundleid:
        logging.error(f"Bundle ID is not set: {infopath}")
        return False

    install_path = os.path.join(install_base, bundleid)
    logging.debug(f"Installing to: {install_path!r}")
    logging.info(f"{action} workflow `{name}` to `{printable_path(install_path)}` ...")

    if os.path.lexists(install_path):
        logging.info("Deleting existing workflow ...")
        if os.path.islink(install_path) or os.path.isfile(install_path):
            os.unlink(install_path)
        else:
            shutil.rmtree(install_path)

    if symlink:
        relpath = os.path.relpath(workflow_dir, os.path.dirname(install_path))
        logging.debug(f"Relative path: {relpath!r}")
        os.symlink(relpath, install_path)
    else:
        shutil.copytree(workflow_dir, install_path)

    return True


def get_workflow_directory():
    """Return path to Alfred's workflow directory."""
    if not os.path.exists(ALFRED_PREFS):
        return os.path.join(DEFAULT_DIR, "Alfred.alfredpreferences", "workflows")

    with open(ALFRED_PREFS, "rb") as fp:
        prefs = json.load(fp)

    workflow_sync_dir = prefs.get("current", "")
    logging.debug(f"Workflow sync directory: {workflow_sync_dir}")
    return os.path.join(workflow_sync_dir, "workflows")


def find_workflow_dir(dirpath):
    """Recursively search `dirpath` for a workflow directory containing an `info.plist` file."""
    for root, _, filenames in os.walk(dirpath):
        if "info.plist" in filenames:
            logging.debug(f"Workflow found at {root!r}")
            return root
    return None


def main():
    """Run the CLI"""
    parser = argparse.ArgumentParser(description="Run the program")
    parser.add_argument("--verbose", action="store_true", help="enable verbose logging")
    parser.add_argument("--quiet", action="store_true", help="enable quiet logging")
    parser.add_argument("--debug", action="store_true", help="enable debug logging")
    parser.add_argument(
        "--symlink", action="store_true", help="use symlink for installing workflow"
    )
    parser.add_argument(
        "workflow_directory", nargs="*", help="workflow directory paths"
    )

    args = parser.parse_args()

    if args.verbose:
        logging.basicConfig(level=logging.INFO)
    elif args.quiet:
        logging.basicConfig(level=logging.ERROR)
    elif args.debug:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.WARNING)

    current_log_level = logging.getLevelName(logging.getLogger().getEffectiveLevel())
    logging.debug(f"Set log level to {current_log_level}")

    workflows_directory = get_workflow_directory()
    logging.debug(f"Workflows directory: {workflows_directory}")

    workflow_paths = args.workflow_directory
    if not workflow_paths:
        cwd = os.getcwd()
        logging.debug(f"Current working directory: {cwd}")
        wfdir = find_workflow_dir(cwd)
        if not wfdir:
            logging.critical(f"No workflow found under {cwd}")
            return 1
        workflow_paths = [wfdir]

    errors = False
    for path in workflow_paths:
        abs_path = os.path.abspath(path)
        logging.debug(f"Processing path: {abs_path}")
        if not os.path.exists(abs_path):
            logging.error(f"Directory does not exist: {abs_path}")
            errors = True
            continue
        if not os.path.isdir(abs_path):
            logging.error(f"Not a directory: {abs_path}")
            errors = True
            continue
        if not install_workflow(abs_path, workflows_directory, args.symlink):
            errors = True

    return 1 if errors else 0


if __name__ == "__main__":
    result = main()
    if result != 0:
        logging.error("An error occurred. Exiting with status code %d.", result)
    else:
        logging.info("Execution completed successfully.")
    exit(result)
