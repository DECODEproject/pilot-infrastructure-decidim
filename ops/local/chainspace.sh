#!/usr/bin/env bash

#set -e # Exit script if anything fails
set -u # unset variables cause an error
set -o pipefail # https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
#set -x # for debugging each command

SCRIPT_HOME=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

source ${SCRIPT_HOME}/_env.sh


CHAINSPACE_API_URL="http://localhost:5000/api/1.0/"


function status {
    echo -e "Status of local chainspace docker:\n"
    echo -e "Docker Config: \n${DOCKER_COMPOSE_CONFIG}\n"
    ${DOCKER_COMMAND} ps chainspace

    HTTP_STATUS=$(lib/http_status_of ${CHAINSPACE_API_URL})

    echo -e "\nStatus of local chainspace api @ ${CHAINSPACE_API_URL}: ${HTTP_STATUS}\n"
}

function docker-logs {
    LOGS_FOLLOW=${1: }
    ${DOCKER_COMMAND} logs ${LOGS_FOLLOW}
}

function logs {
    LOG_SOURCE=$1
    shift

    case ${LOG_SOURCE} in
        "docker")
            docker-logs $@
            ;;
        *)
            echo -e "Don't understand how to show you logs for ${LOG_SOURCE}"
            ;;
    esac
}

function start {
    echo -e "\nStarting local docker container with chainspace (run [${SCRIPT_HOME}/chainspace.sh docker-logs] to see details)\n"
    ${DOCKER_COMMAND} start chainspace
    lib/wait_for_service ${CHAINSPACE_API_URL}
    status
}

function stop {
    echo "Stopping local chainspace docker container ...\n"
    ${DOCKER_COMMAND} stop chainspace
    echo -e "\nChainspace stopped."
}

function restart {
    echo "Restarting local chainspace docker container ...\n"
    ${DOCKER_COMMAND} restart chainspace
    echo -e "\Chainspace stopped."
}

function shell {
    ${DOCKER_COMMAND} exec chainspace bash
}


lib/process_commands $@
