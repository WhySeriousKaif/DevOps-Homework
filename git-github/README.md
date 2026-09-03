# Git and GitHub Fundamentals: DevOps Homework

A comprehensive guide and practical reference for Version Control Systems (VCS), Git internals, branching strategies, and collaborative GitHub workflows for DevOps.

---

## Table of Contents

- [Overview & Importance in DevOps](#overview--importance-in-devops)
- [Git Core Architecture & Three-Tree Model](#git-core-architecture--three-tree-model)
- [Command Summary Cheat Sheet](#command-summary-cheat-sheet)
- [Step-by-Step Hands-On Workflow](#step-by-step-hands-on-workflow)
  - [1. Configuration & Identity](#1-configuration--identity)
  - [2. Repository Initialization & Tracking](#2-repository-initialization--tracking)
  - [3. Staging, Inspecting & Committing](#3-staging-inspecting--committing)
  - [4. Branching & Feature Workflow](#4-branching--feature-workflow)
  - [5. Merging & Conflict Resolution](#5-merging--conflict-resolution)
  - [6. Remote Operations & GitHub Synchronization](#6-remote-operations--github-synchronization)
- [DevOps Collaboration & GitHub Features](#devops-collaboration--github-features)
  - [Pull Requests (PR) & Code Review](#pull-requests-pr--code-review)
  - [Branch Protection & GitOps Integration](#branch-protection--gitops-integration)
- [Verification & Screenshots](#verification--screenshots)
- [Best Practices & Key Learnings](#best-practices--key-learnings)

---

## Overview & Importance in DevOps

Git is a **distributed version control system (DVCS)** that tracks changes in source code across time. In modern DevOps and Cloud Engineering, Git is the single source of truth:
- **Infrastructure as Code (IaC):** Terraform, Ansible, and CloudFormation configurations are versioned in Git.
- **CI/CD Triggers:** Automated pipelines (e.g., GitHub Actions, Jenkins, GitLab CI) trigger builds and tests on `git push` or `pull_request` events.
- **GitOps:** Tools like ArgoCD and Flux synchronize live Kubernetes cluster states directly with declarative Git repositories.
- **Traceability & Auditability:** Every deployment and infrastructure modification is traceable to an author, commit hash, and peer review.

---

## Git Core Architecture & Three-Tree Model

Git manages files across three local distinct zones before synchronizing with a remote:

```text
+---------------------+     git add      +---------------------+    git commit    +---------------------+
|                     | ---------------> |                     | ---------------> |                     |
|  Working Directory  |                  |    Staging Area     |                  |  Local Repository   |
|   (Untracked/Mod)   | <--------------- |       (Index)       |                  |     (HEAD / .git)   |
+---------------------+    git restore   +---------------------+                  +---------------------+
           ^                                                                                 |
           |                                                                                 | git push
           |                                     git pull / git fetch                        v
           +---------------------------------------------------------------------- +---------------------+
                                                                                   |  Remote Repository  |
                                                                                   |      (GitHub)       |
                                                                                   +---------------------+
```

1. **Working Directory:** The sandbox where files are created, edited, and deleted.
2. **Staging Area (Index):** A buffer holding snapshot changes intended for the next commit.
3. **Local Repository (`.git`):** A permanent, immutable ledger storing commits with unique SHA-1/SHA-256 hashes.
4. **Remote Repository (GitHub):** A hosted central repository enabling multi-engineer collaboration.

---

## Command Summary Cheat Sheet

| Category | Command | Description |
|---|---|---|
| **Setup** | `git config --global user.name "Name"` | Sets author name across all local repositories |
| **Setup** | `git config --global user.email "email"` | Sets author email associated with Git commits |
| **Init & Clone** | `git init` | Initializes a new Git repository in current directory |
| **Init & Clone** | `git clone <repo-url>` | Clones an existing remote repository locally |
| **Status & Diff** | `git status` | Shows state of working directory and staging area |
| **Status & Diff** | `git diff` | Shows unstaged modifications between working tree and index |
| **Staging** | `git add <file>` | Adds specific file changes to the staging area |
| **Staging** | `git add .` | Stages all new, modified, and deleted files |
| **Commit** | `git commit -m "msg"` | Commits staged snapshot with a descriptive message |
| **Commit** | `git commit --amend` | Modifies the most recent commit |
| **History** | `git log --oneline --graph` | Displays visual graph of commit history |
| **Branching** | `git branch` | Lists all local branches |
| **Branching** | `git checkout -b <branch>` | Creates and switches to a new branch |
| **Branching** | `git switch -c <branch>` | Modern syntax to create and switch branches |
| **Merging** | `git merge <branch>` | Merges specified branch into the current active branch |
| **Remote** | `git remote add origin <url>` | Links local repository to a remote GitHub URL |
| **Remote** | `git push -u origin <branch>` | Pushes commits and sets upstream tracking branch |
| **Remote** | `git pull` | Fetches and integrates changes from remote branch |

---

## Step-by-Step Hands-On Workflow

### 1. Configuration & Identity

Configure author identity before making commits:

```bash
git config --global user.name "mdkaif"
git config --global user.email "your-email@example.com"
git config --global init.defaultBranch main
git config --list
```

---

### 2. Repository Initialization & Tracking

Initialize a fresh repository or inspect the current directory:

```bash
mkdir my-devops-project
cd my-devops-project
git init
```

Verify the hidden `.git` internal database was created:
```bash
ls -la
```

---

### 3. Staging, Inspecting & Committing

Create project files and inspect git lifecycle transitions:

```bash
echo "# DevOps Project" > README.md
echo "node_modules/" > .gitignore
echo "*.env" >> .gitignore

# Check untracked files
git status

# Stage files
git add README.md .gitignore

# Commit changes
git commit -m "feat: initialize repository with README and .gitignore"

# View commit log
git log --oneline
```

---

### 4. Branching & Feature Workflow

DevOps best practice mandates isolated feature branches to keep `main` production-ready:

```bash
# Create and switch to a feature branch
git switch -c feature/docker-setup

# Create feature work
echo "FROM alpine:latest" > Dockerfile
git add Dockerfile
git commit -m "feat(docker): add base Alpine Dockerfile"

# Check branches
git branch -a
```

---

### 5. Merging & Conflict Resolution

Integrate feature changes into the main branch:

```bash
# Return to main branch
git switch main

# Fast-forward or 3-way merge
git merge feature/docker-setup

# Delete feature branch after merge
git branch -d feature/docker-setup
```

#### Handling Merge Conflicts
When conflicting changes occur on the same lines across branches:
1. Git halts merge and tags files with conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
2. Open conflicting files and resolve differences manually.
3. Re-stage the resolved file: `git add <file>`.
4. Finalize the merge: `git commit -m "merge: resolve conflict between branches"`.

---

### 6. Remote Operations & GitHub Synchronization

Link local repository to GitHub and push:

```bash
# Link remote repository
git remote add origin https://github.com/WhySeriousKaif/DevOps-Homework.git

# Verify remote URL
git remote -v

# Push commits to remote main
git push -u origin main
```

---

## DevOps Collaboration & GitHub Features

### Pull Requests (PR) & Code Review
- Feature branches are pushed to GitHub (`git push origin feature/xyz`).
- A Pull Request is opened against `main`.
- Automated CI checks (linting, tests, security scans) execute automatically.
- Team members review diffs, leave line comments, and approve.

### Branch Protection & GitOps Integration
- **Branch Protection Rules:** Prevent direct pushes to `main`, requiring at least 1 review approval and passing CI status checks.
- **GitOps Triggers:** Once merged, webhook events notify CD operators (e.g., ArgoCD) to deploy changes to staging/production clusters.

---

## Verification & Screenshots

### Screenshot 1: Git Status & Staging Proof
Demonstrating file modification, untracked files detection, and staging transitions.

![Git Status](screenshots/git-status.png)

---

### Screenshot 2: Commit History & Tree Graph
Visualizing commit history graph with hashes, author information, and branch pointers using `git log --oneline --graph --all`.

![Commit History](screenshots/git-log.png)

---

### Screenshot 3: Branching & Merge Execution
Demonstrating feature branch creation, switching, committing, and clean merge into `main`.

![Git Branching & Merge](screenshots/git-branch.png)

---

### Screenshot 4: Remote Push & GitHub Repository
Verifying clean synchronization between local repository and remote GitHub repository.

![GitHub Remote](screenshots/git-remote.png)

---

## Best Practices & Key Learnings

1. **Commit Early and Atomically:** Each commit should represent a single logical unit of work.
2. **Standardize Commit Messages:** Follow Conventional Commits format (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`).
3. **Always Maintain `.gitignore`:** Exclude build artifacts, binary files, environment variables (`.env`), and credentials (`id_rsa`).
4. **Never Rewrite Shared History:** Avoid `git push --force` on shared public branches like `main`.
5. **Pull Before Pushing:** Always run `git pull --rebase` to avoid unnecessary merge commits when collaborating.

---

*Maintained by mdkaif — DevOps Homework Submission*
