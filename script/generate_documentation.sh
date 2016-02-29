#!/bin/bash

version=${1:-"$(git rev-parse HEAD)"}

if hash jazzy 2>/dev/null
then
	out_dir=".build/${version}"
	mkdir -p "${out_dir}"

	jazzy \
		--clean \
		--author SwiftGit2 \
		--author_url https://github.com/SwiftGit2 \
		--github_url "https://github.com/SwiftGit2/SwiftGit2/tree/${version}" \
		--github-file-prefix "https://github.com/SwiftGit2/SwiftGit2/tree/${version}" \
		--module-version "${version}" \
		--module SwiftGit2 \
		--output "${out_dir}"

	echo "Generated document in ${out_dir}"
else
	echo "Please install Jazzy to generate the docs"
	echo "https://github.com/realm/jazzy"
fi

