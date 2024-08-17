#!/usr/bin/python3
import base64
import json
import logging
import os
import urllib.error
import urllib.request
from typing import Optional, Union

domain = os.getenv("domain")
email = os.getenv("email")
api_token = os.getenv("api_token")
projects = os.getenv("projects")

if not all([domain, email, api_token, projects]):
    raise ValueError(
        "One or more arguments are missing. Check your workflow config in Alfred."
    )


def extract_desired_fields(
    issues: list[dict[str, Union[str, dict, list]]],
) -> list[dict[str, str]]:
    """Extract assignee, key, summary, and status name from the issues."""
    logging.info("Parsing desired fields: key, summary, assignee and status.")
    return [
        {
            "key": issue["key"],
            "summary": issue["fields"]["summary"],
            "assignee": issue["fields"]["assignee"]["displayName"]
            if issue["fields"]["assignee"]
            else "Unassigned",
            "status": issue["fields"]["status"]["name"],
        }
        for issue in issues
    ]


def make_request(url: str, payload: dict, headers: dict) -> Optional[dict]:
    """Makes a POST request and handles errors gracefully."""
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        logging.error(f"HTTPError: {e.code} - {e.reason}")
    except urllib.error.URLError as e:
        logging.error(f"URLError: {e.reason}")
    except json.JSONDecodeError as e:
        logging.error(f"JSONDecodeError: {e.msg}")
    return None


def main(start_at: int = 0, max_results: int = 50) -> list[dict[str, str]]:
    url = f"https://{domain}/rest/api/3/search"
    auth = base64.b64encode(f"{email}:{api_token}".encode()).decode()

    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": f"Basic {auth}",
    }

    total_issues = []

    while True:
        logging.info(f"Sending request: {start_at // max_results + 1}")
        payload = {
            "fields": ["summary", "status", "assignee"],
            "jql": f"project in ({projects}) and statusCategory!=Done",
            "maxResults": max_results,
            "startAt": start_at,
        }

        response_json = make_request(url, payload, headers)
        if not response_json:
            break  # Stop on any request failure

        issues = response_json.get("issues", [])
        logging.info(f"Retrieved issues: {start_at}-{start_at + len(issues)}")

        filtered_issues = extract_desired_fields(issues)
        total_issues.extend(filtered_issues)

        if len(issues) < max_results:
            break

        start_at += max_results

    return total_issues


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    result = main()
    print(json.dumps(result, indent=4))
