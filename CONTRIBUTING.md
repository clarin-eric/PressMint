# CONTRIBUTING in PressMint

## Git and GitHub

Sample data should be pushed to the Data branch of the PressMint repository directly into the samples folder
(*`Samples/PressMint-XX`*)

### Setup

- [Create a GitHub account](https://github.com/signup) if you don't have one.
- [Fork PressMint repository](https://github.com/clarin-eric/PressMint/fork) into your organization or private account.
  - uncheck "Copy the main branch only"
- Start the terminal on your computer and navigate to the folder where you want the PressMint local clone of the repository to be placed:

```bash
# replace <USER-ORG> with your GitHub user or organization name
 git clone git@github.com:<USER-ORG>/PressMint.git
```

- (ONLY WHEN YOU FORGET TO UNCHECK "Copy the main branch only") Set the data branch in your repository to be synchronized with the data branch in the PressMint repository:
```bash
cd PressMint
git remote add upstream https://github.com/clarin-eric/PressMint.git
git fetch upstream
git checkout -b data upstream/data
git push -u origin data
```

### Adding new data into your remote repository (Fork)
- check you are in the data branch

```bash
git status
# switch do data branch:
git checkout data
```
- Update your local git repository with your remote repository

```bash
git pull
```

- Add new data to your local git repository
  - eg sample source data:  

```bash
# replace XX with your country code
git add Samples/PressMint-XX/Sources/*
git commit -m 'XX: Source sample' Samples/PressMint-XX/Sources/*
```

- Push data to your Fork:

```bash
git push
```

### Synchronize your remote repository with the PressMint repository

- update your repository with new content in PressMint repository:
  - create a pull request: https://github.com/USER-ORG/PressMint/compare/data...clarin-eric:data
  - check changes
  - merge pull request
- update PressMint repository with data in your repository:
  - create a pull request: https://github.com/clarin-eric/PressMint/compare/data...USER-ORG:data




