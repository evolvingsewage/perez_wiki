#!/bin/bash
# Author: Carl Perez
# Description: Starts the Perez Wiki Website with gunicorn

usage() {
    echo -e "Usage: ./$0 [-d]"
    echo -e "  -d       Development Mode - use this to avoid using gunicorn"
    echo -e "               DO NOT DO THIS IN PRODUCTION ENVIRONMENTS"
}

MODE="production"
# let's parse args!
while getopts ":d" o; do
    case "${o}" in
        d)
            MODE="development"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Start the website in the specified mode
# Globals:
#   MODE
# Arguments:
#   None
# Returns:
#   None
start_perez() {
    source venv/bin/activate
    if [[ "${MODE}" == "development" ]]; then
        export FLASK_DEBUG=1
        export FLASK_APP="perez"
        flask run
    else
        gunicorn --workers 4 --bind unix:perez_wiki.sock -m 007 wsgi:gunicorn_app
    fi
}

start_perez
