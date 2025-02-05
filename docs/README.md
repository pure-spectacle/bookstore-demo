# Bookstore demo guide

The bookstore demo provides an automatically provisioned demo environment to allow you to deliver an end-to-end demo using GitHub Flow, issues, actions, packages, code scanning and private token scanning.

The demo also showcases several workflows including events like `push`, `pull_request`, `deployment` and `workflow_dispatch` and code scanning, container scanning and CI/CD workflows using Azure as backend. 


## Table of contents 

- [Prerequisites](#prerequisites)
- [Preparation](#preparation)
- [Minimal demo](#minimal-demo)
- [End-to-end demo](#end-to-end-feature-demo)
- [Teardown](#teardown)

## Prerequisites

To use the bookstore demo you need to be a member of an organization that supports `demo bootstrap`, as that is what provisions the demo and associated cloud resources.

You will need a separate GitHub user to act as an approver of pull requests unless you want to leverage the override support in the branch protections.
Also, optionally, you may want one more user to act as a project/product manager if performing a comprehensive demo of SDLC processes with mulitple personas.


## Preparation

Create a new demo environment by opening an issue utilizing a demo template in your `bootstrap` repository on the organization.

### Outcome

The bootstrap workflow creates:

- A repository with the given name with a feature request issue and optionally a project board with to do, in progress and done columns.
- A container built from the main branch with a version number of 1.0.0-<sha> and deployed to the container registry. The name of the container will mirror that of the repository name so as to avoid conflicts/collisions from other demos.
- An Azure backend resource group with a unique name that is namespaced based on the organization, github instance and the repository name. This is populated into a secret on the repository `AZURE_RESOURCE_GROUP_NAME`.
- A production environment with a deployment from the container built from the `main` branch.
- Code scanning and container scanning workflows triggered for the `main` branch with results reported in the Security Scanning tab of the repository (GHAS integration).
  - The container scanning leverages a reusable workflow in the organization common-workflows to simulate a centralized DevSecOps team provising paved path workflows users can compose from 
- Branch protection is configured for the `main` branch with rules for required reviews (1) and a required status for `Build (ubuntu-20.04, 11)`.

### A few notes

- The repository has a number of activities to bring into into service with respect to actions workflows. Some initial workflows that trigger as we populate the repository files will fail until the provisioning is 100% complete (as we need to set configuration settings and secrets). There is an intitialization workflow that will be trigger right at the end of the demo resource provisioning that will cause the workflows to rerun and deploy to our "production" environment ready to demo from. 
- We decided to make deploys to test, QA and Staging not unique per pull request, so if you demo multiple pull requests one deployment to test will overwrite any other existing deployment to test.
- Dependabot security and version updates are configured and active by default. This will generate a number of PRs to update these to show the functionality. The `junit` dependency is purposely set to an out of date version that has a known security vulnerability in it.

If this is the first time you use the demo, before delivering the demo it is best to familiarize yourself with the repository and the workflows. The demo can be used for many purposes, but here are two "major" narratives that you can use.

## Minimal demo

For a minimal demo you can just make some changes in the file `BookService.java`: 

- Comment out one or more books to break the build or make changes to some of the book data like an author or title if you do not want to break the build.
- Open a pull request for the changes.
- Create a deployment for example by adding the label `Deploy to test` to create a test environment that reflects your changes.

## End-to-end feature demo 

For an end-to-end feature demo it is best to clone the repository to your local machine and open the project for example in VSCode.

### Steps

1. Show the prod environment with the deployment for the current main branch. This is the initial production deployment.
2. Go to the `Add a rating feature to the bookstore` issue and show the customer what you will be implementing. You can also use this issue to discuss projects and issues.
3. If you use the project board add the issue to the To do list on the project board.
4. Open the repository in Codespaces. :bulb: **Tip** Consider creating a codespace before the demo; it takes a few minutes to create a new codespace vs a few seconds to open an existing one. Also note, codespaces that are not in use for over 30mins will go into suspended state, which is still faster to come from than build a new one.
5. Explain how Codespaces work.
6. Hit `F5` or use `Run -> Start Debugging` menu. Go to `PORTS` section, that the application is currently running locally. Open it by opening the URL in `Local Address` column and show the current state of the application. Stop the application by pressing `Shift+F5`, selecting `Run -> Stop Debugging` from the menu or clicking on `Stop` button
7. Open Command Palette (`Command+Shift+P` or `View -> Command Palette`), type `run task` and hit `Enter`. Select `demo: code feature`. You'll have an option to choose `book-star-rating` and `book-search`. `book-star-rating` will run a script to implement star rating feature. `book-search` will introduce an SQL injection vulnerability which will be picked up by CodeQL. You'll have an option to provide a branch name or leave it empty and a branch will be created for you. (There are no more scripts in `./scripts/code-feature.sh` to make code changes)
8. Show the changes, add and commit the changes to the branch.
9. Use the steps above to start the application and show how the new feature looks in the local environment.
9. Push the branch to the server. Do not elect to create a pull request within codespaces unless you want to show that functionality.
10. On GitHub create a Draft pull request for the new branch and include a link to the issue #1.
11. Show and explain the checks in Pull Request. This is a good time to let audience to ask questions while the checks are running.   
9. On a non-critical path three additional security workflows are triggered:
    1. **Code scanning** will introduce introduce a [Query built from user-controlled sources](https://help.semmle.com/wiki/display/JAVA/Query+built+from+user-controlled+sources) vulnerability because a query in the `BookService` class is built using string concatenation, and the concatenation includes user input (the `name` parameter). If you include user input and do not validate that input, the user could inject and run a malicious query.
    1. **Anchore (Grype) container scanning** that will introduce a bunch of additional container vulnerabilities in the Code scanning alerts through a SARIF report.
    1. **Secret scanning** adding a detected secret for a Google API key
10. On your local machine fix the issues by uncommenting the 2 books in the `BookService.java` and commit and push the changes.
11. To resolve the code scanning alert make the following changes:

```java
String query = "SELECT * FROM Books WHERE name LIKE ? ";
PreparedStatement statement = connection.prepareStatement(query);
statement.setString(1, "%"+ name +"%");
ResultSet results = statement.executeQuery();
```

When you push this change it will close the code scanning alert. Visit the Code scanning alerts page in the security tab to show the closed alert. You might have to select the feature branch to find the alert.

12. Add the Deploy to test label to deploy the current pull request. It will create a test environment.
13. Click Ready for review
14. As a reviewer show code review. As a general comment you can request the developer to add unit tests for the rating feature. Submit your review by requesting changes.
15. As a developer, locally run `./scripts/code-test.sh` to add the unit tests for the rating feature and commit and push the changes.
16. As a reviewer check the changes since the last review and approve the change that added the unit tests.
17. As a developer optionally deploy to QA and/or staging.
18. Merge the rating feature in the main branch. This will trigger a workflow to update the production environment reflecting the changes from the pull request.
19. Show the updated production environment. :checkered_flag:

## Teardown

:warning: **Note** It is highly recommended teardown your demo after use. This will release any Cloud based resources in the Azure backend as well as remove the repository from the Azure subscription.

:warning: **Note**  The teardown can take up to 5 minutes due to Azure clean up.

The Automation for creating a new demo completes in around 5 minutes or less. By tearing down the demo and then recreating it using the Issue ticket you can have demos that are clean, isolated and repeatable.

Go back to the issue in the bootstrap repository and close your issue to trigger the destruction workflow. It will delete all resources in Azure and the repository.
