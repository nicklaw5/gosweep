# GoSweep

This script performs the build, test and automatic checking of a Go package and its sub-packages using:

- [gofmt][gofmt]
- [goimports][goimports]
- [golint][golint]
- [go vet][go_vet]
- [ineffassign][ineffassign]
- [race detector][race_detector]
- [test coverage][test_coverage] on package and its sub-packages, `/vendor` directories excluded
- [goveralls][goveralls]
- [misspell][misspell]

## Dependencies

To setup all the dependencies need to run the script do:
```
$ go get -v golang.org/x/tools/cmd/goimports
$ go get -v github.com/golang/lint/golint
$ go get -v github.com/gordonklaus/ineffassign
$ go get -v github.com/client9/misspell/cmd/misspell
$ go get -v github.com/nicklaw5/gosweep
$ go get -v github.com/mattn/goveralls
$ go get -v github.com/Masterminds/glide
```

## Environment variables

- **MISSPELL_LOCALE**: English locale (default: `US`).

## Continuous Integration

### travis-ci

Example of `.travis.yml` file for Go:

```yaml
language: go
cache:
  directories:
    - ${GOPATH}/src/github.com/${TRAVIS_REPO_SLUG}/vendor
    - ${GOPATH}/src/github.com/nicklaw5
    - ${GOPATH}/src/github.com/Masterminds
    - ${GOPATH}/src/github.com/mattn
go:
  - tip
  - 1.8
  - 1.7
  - 1.6
sudo: false

env:
    CI_SERVICE=travis-ci

install:
  - go get -v golang.org/x/tools/cmd/goimports
  - go get -v github.com/golang/lint/golint
  - go get -v github.com/gordonklaus/ineffassign
  - go get -v github.com/client9/misspell/cmd/misspell
  - go get -v github.com/nicklaw5/gosweep
  - go get -v github.com/mattn/goveralls
  - go get -v github.com/Masterminds/glide
  - glide install

script:
  - bash ${GOPATH}/src/github.com/nicklaw5/gosweep/gosweep.sh
```


[go_vet]:	http://golang.org/cmd/vet	"go vet"
[gofmt]:	http://golang.org/cmd/gofmt/	"gofmt"
[goimports]:	https://godoc.org/golang.org/x/tools/cmd/goimports	"golang.org/x/tools/cmd/goimports"
[golint]:	https://github.com/golang/lint	"golang/lint"
[goveralls]:	https://github.com/mattn/goveralls	"mattn/goveralls"
[ineffassign]: https://github.com/gordonklaus/ineffassign "ineffassign"
[misspell]: https://github.com/client9/misspell "misspell"
[race_detector]:	http://blog.golang.org/race-detector	"race detector"
[test_coverage]:	http://blog.golang.org/cover	"test coverage"
