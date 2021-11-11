# GIT Repo Template

<!-- markdownlint-disable MD013 -->

Welcome to the *GIT Repo Template*. This repository is a template
for various documentation created in *Markdown*. It contains the necessary
structures, base documents and CI pipelines for the automatic creation of these
documents. When creating a new *Trivadis Markdown Doc*, this repository can be
used directly as a template. Corresponding links and references in the Markdown
files have to be adapted to the new repository afterwards. In general, these are
just the links in this [README.md](README.md).

## Downloads and Latest Builds

The official release documents are always attached to the pipelines as artifact.

Nightly Builds respectively builds on commit are attached as artifact to the
Azure DevOps pipeline.

## Files and Folders

- [doc](doc) English documentation files.
- [images](images) Images and logo files.
- [AUTHOR_GUIDE](AUTHOR_GUIDE.md) General author's guide to *Markdown Doc
  Template*. This has to be adapted to the corresponding guideline.
- [CHANGELOG](CHANGELOG.md) Change log for the *Markdown Doc Template*.

## Releases and Versions

You find all official releases and release information on the Azure DevOps
project release page. As well documented in the [CHANGELOG](CHANGELOG.md).

The versioning and release tags follow the [semantic versioning](https://semver.org/).
A version number is specified by MAJOR.MINOR.PATCH, increase the:

- *MAJOR* version when you make incompatible API changes,
- *MINOR* version when you add functionality in a backwards compatible manner, and
- *PATCH* version when you make backwards compatible bug fixes.

Additional labels for pre-release and build metadata are available as extensions
to the MAJOR.MINOR.PATCH format.

## How to Contribute

It is highly recommended to take into account [CONTRIBUTING](CONTRIBUTING.md) and [AUTHOR_GUIDE](AUTHOR_GUIDE.md) when contributing to this *Markdown Doc Template*. However contributing covers the following steps.

1. [Fork this respository](https://github.com/oehrlis/oradba-repo/fork)
2. [Create a branch](https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/), commit and publish your changes and enhancements
3. [Create a pull request](https://help.github.com/articles/creating-a-pull-request/)

## License

**oradba-repo** is licensed under the Apache License 2.0. You may obtain a
copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>.
