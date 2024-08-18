# Jira Workflow

An Alfred workflow to help with basic Jira navigation e.g. opening tickets and boards.

### Commands

- `ji`: Searches Jira for issues relating to the projects you have defined in the workflow configuration, then opens the selected issue in your default browser.
- `jb`: Searches Jira for boards relating to the projects you have defined in the workflow configuration, then opens the selected board in your default browser.
- `jwd`: Misc workflow debugging commands e.g. clearing and opening workflow cache directory.

### Prerequisites

You will need a Jira account and an [API token](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

The workflow has a few dependencies which can be installed via [Homebrew](https://brew.sh/):

- `jq`: a command line tool for parsing JSON ([source code](https://github.com/jqlang/jq))
	- `brew install jq`
- `fzf`: a command line tool for fuzzy searching ([source code](https://github.com/junegunn/fzf))
	- `brew install fzf`
- `imagemagick`: a command line tool for manipulating images ([source code](https://github.com/ImageMagick/ImageMagick))
	- `brew install imagemagick`

### Troubleshooting

This workflow caches responses from the Jira API for responsivenes, then updates the caches when the command is run. If you are experiencing issues you may need to clear the cache using the `jwd` command.

Enabling avatars in the workflow config requires `imagemagick` to process the images to have circlular backgrounds as Jira generates and aligns the "initials" avatar images inconsistently.
