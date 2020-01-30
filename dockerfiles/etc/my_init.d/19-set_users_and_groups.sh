#!/bin/bash
# Environment vars passed at run

# Volumes are not well mounted in Travis due to being siblings.
# travis user doesn't exist on the host of the Travis container so is not
# available through volumes
if [ ! -z "$ETC_PASSWD_64" ]
then
    base64 --decode <<< "$ETC_PASSWD_64" > /etc/passwd;
    base64 --decode <<< "$ETC_GROUP_64" > /etc/group;
    base64 --decode <<< "$ETC_SHADOW_64" > /etc/shadow;
fi
