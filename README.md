# README

- How to run the application?
1. Clone the repository.

2. Cd into the respository and run "bundle install".

3. You may also need to run "yarn install --check-files".

4. Update database username and password in database.yml.

5. Create the database by running "rails db:create"

6. Run the migrations by running "rails db:migrate"

7. Run "rails server" or "rails s" to start the server.

8. Access the web-application at 127.0.0.1:3000

Before any of this, you will need to create a .env file in the root directory of the application and paste the following into it.

EMAIL_PASSWORD=EHMail123
EMAIL_USERNAME=ehtamumailer@gmail.com
HASHER=QETXIEJWBYRCFOKESHWDYWIOWJTRXGZN

- How to run security tests?
1. Type "brakeman" in the root directory of the application and it will generate a report.

- How to perform CI?
1. Any PR submitted to heroku-live or dev branch will run the CI automated tests. It will output the results on the PR.
2. This is how it was setup on our personal Git repository. We have tranferred the workflow to the classroom repository, but it may need to be setup again.

- How to deploy code to Heroku?
1. Originally, we had our Git repository hooked up to Heroku pipeline, so anytime we would push to heroku-live, it would automatically deploy to our application. However, we were told to remove the Git repository from Heroku as we passed it on to our client. You can easily set this up again by hooking up the respective Git repository in Heroku and enabling automatic deployments from "heroku-live" branch. You could also use the manual deployment button if needed.

We treat heroku-live as our master branch. This is just here to follow requirements.
