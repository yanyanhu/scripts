#!/bin/bash
#
# References:
# [1] https://docs.gitlab.com/runner/install/docker.html
# [2] https://docs.gitlab.com/runner/register/index.html#docker
#

echo "Create config volume"
docker volume create gitlab-runner-config

echo "Boot up gitlab-runner docker instance"
docker run -d --name gitlab-runner --restart always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v gitlab-runner-config:/etc/gitlab-runner \
    gitlab/gitlab-runner:latest


# Run the following cmd manually to config the runner
#docker run --rm -it -v gitlab-runner-config:/etc/gitlab-runner gitlab/gitlab-runner:latest register
