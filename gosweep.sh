#!/bin/bash
#
# The script does automatic checking on a Go package and its sub-packages, including:
#
# 1. test
# 2. gofmt
# 3. goimports
# 4. golint
# 5. go vet
# 6. ineffassign
# 7. race detector
# 8. misspell (.go files)
# 9. misspell (.txt .md .rst files)
# 10. test coverage
# 11. goveralls

set -e

go build $(go list ./... | grep -v '/vendor/')

echo 'mode: count' > profile.cov

locale="${MISSPELL_LOCALE:-US}"
max_steps=11

for pkg in $(go list ./... | grep -v '/vendor/');
do
    dir="$GOPATH/src/$pkg"
    len="${#PWD}"
    dir_relative=".${dir:$len}"


    # 1. test
    echo "go test $pkg ... (1/$max_steps)"
    go test -v -short -covermode=count -coverprofile="$dir_relative/profile.tmp" "$dir_relative"
    if [ -f "$dir_relative/profile.tmp" ]
    then
        cat "$dir_relative/profile.tmp" | tail -n +2 >> profile.cov
        rm "$dir_relative/profile.tmp"
    fi

    # 2. fmt
    echo "gofmt $pkg ... (2/$max_steps)"
    gofmt -l -w "$dir"/*.go

    # 3. imports
    echo "goimports $pkg ... (3/$max_steps)"
    goimports -l -w "$dir"/*.go | tee /dev/stderr

    # 4. lint
    echo "golint $pkg ... (4/$max_steps)"
    golint $pkg | tee /dev/stderr

    # 5. vet
    echo "go vet $pkg ... (5/$max_steps)"
    go vet $pkg | tee /dev/stderr

    # 6. ineffassign
    echo "ineffassign $pkg ... (6/$max_steps)"
    ineffassign -n $dir | tee /dev/stderr

    # 7. race conditions
    echo "race detector $pkg ... (7/$max_steps)"
    env GORACE="halt_on_error=1" go test -short -race $pkg

done

# 8. misspell over .go files
echo "misspell *.go (8/$max_steps)"
find . -type f -name '*.go' -not -path './vendor/*' | xargs -I {} -P 2 misspell -error -source go {}

# 9. misspell over .txt .md .rst files
echo "misspell text files... (9/$max_steps)"
find . -type f -not -path './vendor/*' \( -name '*.md' -o -name '*.txt' -o -name '*.rst' \) | xargs -I {} misspell -error -source text {}

# 10. test coverage
echo "go tool cover (10/$max_steps)"
go tool cover -func profile.cov

# 11. goveralls
if [ -n "${CI_SERVICE+1}" ]; then
    echo "goveralls with ${CI_SERVICE}"
    if [ -n "${COVERALLS_TOKEN+1}" ]; then
        goveralls -coverprofile=profile.cov -service=$CI_SERVICE -repotoken $COVERALLS_TOKEN
    else
        goveralls -coverprofile=profile.cov -service=$CI_SERVICE
    fi
fi

echo "done. (11/$max_steps)"
