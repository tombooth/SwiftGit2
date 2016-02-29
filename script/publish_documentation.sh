#!/bin/bash

version=${1:-"$(git rev-parse HEAD)"}
doc_dir=".build/${version}"

if [ -d "${doc_dir}" ]
then
	git checkout gh-pages
	cp -r "${doc_dir}" "${version}"
	echo "<!DOCTYPE html><meta http-equiv=\"refresh\" content=\"0;URL='${version}'\" />" > index.html
	git add "${version}" index.html
	git commit -m "Adding documentation for ${version}"
	git push origin gh-pages
else
	echo "Cannot find a version of the documentation to publish"
fi
