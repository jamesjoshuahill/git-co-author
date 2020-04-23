# git-co-author

Easily add `Co-authored-by` trailers to the commit template.

This command enables pairs and mobs of programmers to attribute commits to all the authors. GitHub has first-class support for `Co-authored-by` trailers and recognises the author and co-authors of commits.

For more information on co-authoring commits:
- [Git Together By Co-Authoring Commits](https://github.community/t5/Support-Protips/Git-Together-By-Co-Authoring-Commits/ba-p/27480)
- [Creating a commit with multiple authors](https://help.github.com/en/github/committing-changes-to-your-project/creating-a-commit-with-multiple-authors)

Inspired by [`git-author`](https://github.com/pivotal/git-author).

## Install

Install the commands:

```bash
install git-solo /usr/local/bin
install git-co-author /usr/local/bin/
```

Configure the commit template path:

```bash
git config --global commit.template '~/.git-template'
```

Ensure there is a commit template file:

```bash
touch '~/.git-template'
```

## Configure co-authors

Configure a co-author using their initials. For example 'aa' and 'bb':

```bash
git config --global co-authors.aa 'Ann Author <ann.author@example.com>'
git config --global co-authors.bb 'Bob Book <bob.book@example.com>'
```

You must use the email address associated with your GitHub account. For more information, see [Setting your commit email address](https://help.github.com/en/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address#setting-your-commit-email-address-on-github).

## Choose co-authors

`git co-author` only changes `Co-authored-by` trailers. The rest of the commit template is unchanged.

Update co-authors in the commit template:

```bash
$ git co-author aa     # pair
Co-authored-by: Ann Author <ann.author@example.com>

$ git co-author aa bb  # mob
Co-authored-by: Ann Author <ann.author@example.com>
Co-authored-by: Bob Book <bob.book@example.com>
```

Remove all co-authors from the commit template:

```bash
$ git solo
```

## Commit

Your next commit will include the commit template:

```bash
git commit
```

Important: the commit template is not used when the `-m` flag is used:

```bash
git commit -m "This message will not include the commit template"
```
