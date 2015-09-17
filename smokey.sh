#!/bin/bash
# Check that we get a http 200 from each web application
# @todo - move this to https://github.com/ryotarai/infrataster

srunner_response=$(curl --write-out %{http_code} -L --silent --output /dev/null $1)
author_response=$(curl --write-out %{http_code} -L --silent --output /dev/null $2)

if [[ $srunner_response == 200 && $author_response == 200 ]]; then
  exit 0
else
  exit 1
fi
