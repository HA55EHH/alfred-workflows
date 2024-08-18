response="$1"

# Assume $response contains the JSON response from your curl request
avatars=$(echo "$response" | jq -r '.issues[].fields.assignee | select(. != null) | "\(.displayName)\t\(.avatarUrls."48x48")"')

# Debugging: print the avatars output
echo "Avatars: $avatars" >&2

# Check if $avatars is empty
if [ -z "$avatars" ]; then
    echo "No avatars found." >&2
    exit 1
fi

# Loop through each avatar URL
echo "$avatars" | while IFS=$'\t' read -r displayName url; do
    # Debugging: print each displayName and url
    echo "Processing avatar for: $displayName with URL: $url" >&2

    # Create a filename using the displayName (replace spaces with underscores)
    filename="${displayName}.png"

    # Check if the file already exists in $alfred_workflow_cache
    if [ ! -f "$alfred_workflow_cache/$filename" ]; then
        # Download the avatar, follow redirects, and handle query parameters properly
        curl --silent -L --output "$alfred_workflow_cache/$filename" "$url"
        
        # Check if the downloaded file is valid (not zero bytes)
        if [ ! -s "$alfred_workflow_cache/$filename" ]; then
            echo "Failed to download image for $displayName, removing zero-byte file." >&2
            rm "$alfred_workflow_cache/$filename"
        else
            # Convert the image to a circular format using ImageMagick
            convert "$alfred_workflow_cache/$filename" -resize 48x48 -gravity center -background none -extent 48x48 -alpha set -channel A -evaluate set 0 +channel \( +clone -threshold -1 -negate -fill white -draw "circle 24,24 24,3" \) -compose copy-opacity -composite "$alfred_workflow_cache/$filename"
        fi
    fi
done