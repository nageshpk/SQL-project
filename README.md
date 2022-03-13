# SQL-project

This is a SQL yammer case study from MODE analytics training.

Analyze the Drop in user engagement for yammer. 
There is sharp drop (14% week over weeek) in user engagement from last week of July to first week of August and after that a gradual drop.

# The problem
You show up to work Tuesday morning, September 2, 2014. The head of the Product team walks over to your desk and asks you what you think about the latest activity on the user engagement dashboards. You fire them up, and something immediately jumps out:

https://app.mode.com/modeanalytics/reports/cbb8c291ee96/runs/7925c979521e/viz1/cfcdb6b78885

The above chart shows the number of engaged users each week. Yammer defines engagement as having made some type of server call by interacting with the product (shown in the data as events of type "engagement"). Any point in this chart can be interpreted as "the number of users who logged at least one engagement event during the week starting on that date."

You are responsible for determining what caused the dip at the end of the chart shown above and, if appropriate, recommending solutions for the problem.


# The Data :
  
  The tables used for this case study are:
  
 - Users
 - Emails
 - Events


# Steps to analyze:

- Identify the reason for user engagement drop.
  -  Users are logging in less
  -  Engagement across mobile app platform has dropped, may be due to recent app changes or updates.
  -  Drop in email clockthrough's.
- Make recommendation.
  - Change in mobile app UX or revert any recent update
  - Inspite of weekly digest being sent there is a drop in email clickthrough's, it might be because the information might not be relevant or too much spamming the users' mailbox. So look into the weekly digest being sent over mail.




