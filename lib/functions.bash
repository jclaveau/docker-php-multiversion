function in_docker_container() {
    # TODO check that the container is of jclaveau/php-multiversion
    if [[ -f /.dockerenv ]] || grep -Eq '(lxc|docker)' /proc/1/cgroup; then
        return 0
    else
        return 1
    fi
}

function install_docker_if_missing() {
    docker_path=$(command -v docker)
    if [ -z "$docker_path" ]; then
        # echo "docker not installed"
        echo $docker_path
        read -p "Do you want to install docker? " -n 1 -r
        # echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sudo apt-get install docker
        fi
    fi
}

function run_docker() {
    LIBRARY_DIR=$1
    CONTAINER_NAME=php-mv'_'$(echo $LIBRARY_DIR | sed "s|[^[:alpha:].-]|_|g")
        
    if [ -z "$(docker ps -a | grep $CONTAINER_NAME$)" ]; then
        # echo "Running new docker jclaveau/php-multiversion for $(pwd)"
        if [ "$HOME" != "$LIBRARY_DIR" ]; then
            lib_volume_option="--volume $LIBRARY_DIR:$LIBRARY_DIR" 
        else
            lib_volume_option=''
        fi
        
        docker run \
            -d \
            --rm \
            --volume=$HOME:$HOME:ro \
            --volume=$HOME/.composer:$HOME/.composer:rw \
            $lib_volume_option \
            --volume=/etc/group:/etc/group:ro \
            --volume=/etc/passwd:/etc/passwd:ro \
            --volume=/etc/shadow:/etc/shadow:ro \
            --volume=/etc/sudoers.d:/etc/sudoers.d:ro \
            --name $CONTAINER_NAME \
            --workdir $LIBRARY_DIR \
            jclaveau/php-multiversion > /dev/null
    fi
}

function exec_in_docker() {
    # avoid https://stackoverflow.com/questions/43099116/error-the-input-device-is-not-a-tty
    test -t 1 && USE_TTY="-t" 

    docker exec -i ${USE_TTY} \
        --user $(id -u):$(id -g) \
        $CONTAINER_NAME "$@"
}

function latest_php_version() {
    exec_in_docker update-alternatives --query php | grep Best | sed "s/^[^[:digit:]]*//"
}

function kill_containers() {
    container_ids=$(
        docker ps --format '{{.ID}} {{.Image}}' | awk '$2 ~ /^jclaveau\/php-multiversion(:\w+)?$/ { print $1}'
    )
    
    if [ -n "$container_ids" ]; then
        docker kill $container_ids
    fi
}
