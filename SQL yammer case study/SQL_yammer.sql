/*Weekly active Users*/

SELECT  DATE_TRUNC('week', occurred_at),
        COUNT(DISTINCT user_id) AS weekly_active_users
FROM tutorial.yammer_events
WHERE event_type = 'engagement' AND event_name = 'login'
GROUP BY 1
ORDER BY 1

/*Growth - all users v/s active users*/

SELECT  DATE_TRUNC('day', created_at),
        COUNT(*) AS all_users,
        COUNT(DISTINCT CASE WHEN activated_at IS NOT NULL THEN user_id ELSE NULL END) AS active_users
FROM tutorial.yammer_users
WHERE created_at >= '2014-06-01'
  AND created_at < '2014-09-01'
GROUP BY 1
ORDER BY 1

/*Percent change in User engagement*/

/*
While visualizing this query we can create a
calculated field of SUM(growth) / SUM(users) to create a percentage value.
*/

WITH table2 AS (
  SELECT  DATE_TRUNC('week', occurred_at) AS week,
          COUNT(DISTINCT user_id) AS users
  FROM tutorial.yammer_events
  WHERE event_type = 'engagement' AND event_name = 'login'
  GROUP BY 1
  ORDER BY 1
  )
SELECT  week,
        users,
        (users - LAG(users, 1) OVER (ORDER BY week))  AS growth
FROM table2


/*User base across countries*/

SELECT  location,
        COUNT(DISTINCT user_id) AS user
FROM tutorial.yammer_events
WHERE occurred_at >= '2014-05-01' AND occurred_at < '2014-09-01'
GROUP BY 1
ORDER BY 2 DESC



/*Engagement types*/

SELECT  DATE_TRUNC('week', occurred_at),
        COUNT(DISTINCT CASE WHEN event_name = 'login' THEN user_id ELSE NULL END) AS logins,
        COUNT(DISTINCT CASE WHEN event_name IN ('search_click_result_8', 'search_click_result_6', 'search_click_result_9', 'search_click_result_1', 'search_click_result_10', 'search_click_result_7',
          'search_click_result_3', 'search_click_result_4', 'search_click_result_2', 'search_click_result_5') THEN user_id ELSE NULL END) AS search_clicks,
        COUNT(DISTINCT CASE WHEN event_name = 'search_run' THEN user_id ELSE NULL END) AS search_runs,
        COUNT(DISTINCT CASE WHEN event_name = 'send_message' THEN user_id ELSE NULL END) AS message,
        COUNT(DISTINCT CASE WHEN event_name = 'view_inbox' THEN user_id ELSE NULL END) AS inbox,
        COUNT(DISTINCT CASE WHEN event_name = 'like_message' THEN user_id ELSE NULL END) AS like,
        COUNT(DISTINCT CASE WHEN event_name = 'home_page' THEN user_id ELSE NULL END) AS home_page
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
GROUP BY 1
ORDER BY 1


/*Engagement across top 5 countries by user base*/

SELECT  DATE_TRUNC('week', occurred_at) AS week,
        location,
        COUNT(DISTINCT user_id) AS users
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
AND location IN (
  SELECT  a.location
  FROM (
    SELECT  location,
            COUNT(DISTINCT user_id) AS total_users
    FROM tutorial.yammer_events
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 5
    ) a
    )
GROUP BY 1, 2
ORDER BY 3 DESC

/*Age of users since sign-up*/

SELECT  DATE_TRUNC('week', z.occurred_at) AS "week",
        AVG(z.age_at_event) AS "Average age during week",
        COUNT(DISTINCT CASE WHEN z.user_age > 70 THEN z.user_id ELSE NULL END) AS "10+ weeks",
        COUNT(DISTINCT CASE WHEN z.user_age < 70 AND z.user_age >= 63 THEN z.user_id ELSE NULL END) AS "9 weeks",
        COUNT(DISTINCT CASE WHEN z.user_age < 63 AND z.user_age >= 56 THEN z.user_id ELSE NULL END) AS "8 weeks",
        COUNT(DISTINCT CASE WHEN z.user_age < 56 AND z.user_age >= 49 THEN z.user_id ELSE NULL END) AS "7 weeks",
        COUNT(DISTINCT CASE WHEN z.user_age < 49 AND z.user_age >= 42 THEN z.user_id ELSE NULL END) AS "6 weeks",
        COUNT(DISTINCT CASE WHEN z.user_age < 42 AND z.user_age >= 35 THEN z.user_id ELSE NULL END) AS "5 weeks",
        COUNT(DISTINCT CASE WHEN z.user_age < 35 AND z.user_age >= 28 THEN z.user_id ELSE NULL END) AS "4 weeks",
        COUNT(DISTINCT CASE WHEN z.user_age < 28 AND z.user_age >= 21 THEN z.user_id ELSE NULL END) AS "3 weeks",
        COUNT(DISTINCT CASE WHEN z.user_age < 21 AND z.user_age >= 14 THEN z.user_id ELSE NULL END) AS "2 weeks",
        COUNT(DISTINCT CASE WHEN z.user_age < 14 AND z.user_age >= 7 THEN z.user_id ELSE NULL END) AS "1 week",
        COUNT(DISTINCT CASE WHEN z.user_age < 7 THEN z.user_id ELSE NULL END) AS "Less than a week"
FROM (
    SELECT  e.occurred_at,
            u.user_id,
            DATE_TRUNC('week', e.occurred_at) AS activation_week,
            EXTRACT('day' from e.occurred_at - u.activated_at) AS age_at_event,
            EXTRACT('day' from '2014-09-01':: timestamp - u.activated_at) AS user_age
    FROM tutorial.yammer_users u
    JOIN tutorial.yammer_events e
    ON e.user_id = u.user_id
    AND e.event_type = 'engagement'
    AND e.event_name = 'login'
    AND e.occurred_at >= '2014-05-01'
    AND e.occurred_at < '2014-09-01'
    WHERE u.activated_at IS NOT NULL
    ) z
GROUP BY 1
ORDER BY 1
LIMIT 100

/*Engagement across platforms - mobile/desktop/tablet */


SELECT  DATE_TRUNC('week', occurred_at),
        COUNT(DISTINCT CASE WHEN device IN ('amazon fire phone', 'nexus 10', 'iphone 5', 'nexus 7', 'iphone 5s', 'nexus 5', 'htc one',
                                            'iphone 4s','samsung galaxy note', 'nokia lumia 635', 'samsung galaxy s4') THEN user_id ELSE NULL END) AS mobile,
        COUNT(DISTINCT CASE WHEN device IN ('ipad mini', 'samsung galaxy tablet', 'kindle fire', 'ipad air') THEN user_id ELSE NULL END) AS tablet,
        COUNT(DISTINCT CASE WHEN device IN ('dell inspiron desktop', 'macbook pro', 'asus chromebook', 'windows surface', 'macbook air',
              'lenovo thinkpad', 'mac mini', 'acer aspire desktop', 'acer aspire notebook', 'dell inspiron notebook', 'hp pavilion desktop') THEN user_id ELSE NULL END) AS desktops
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
GROUP BY 1
ORDER BY 1



/*% change in engagement from mobile*/

/*
While visualizing this query we can create a
calculated field of SUM(usage) / SUM(mobile) to create a percentage value.
*/

WITH table1 AS (  SELECT  DATE_TRUNC('week', occurred_at) AS week,
          COUNT(DISTINCT CASE WHEN device IN ('amazon fire phone', 'nexus 10', 'iphone 5', 'nexus 7', 'iphone 5s', 'nexus 5', 'htc one',
                                              'iphone 4s', 'samsung galaxy note', 'nokia lumia 635', 'samsung galaxy s4') THEN user_id ELSE NULL END) AS mobile,
          COUNT(DISTINCT CASE WHEN device IN ('dell inspiron desktop', 'macbook pro', 'asus chromebook', 'windows surface', 'macbook air', 'lenovo thinkpad',
                                              'mac mini', 'acer aspire desktop', 'acer aspire notebook', 'dell inspiron notebook', 'hp pavilion desktop') THEN user_id ELSE NULL END) AS desktop,
          COUNT(DISTINCT CASE WHEN device IN ('ipad mini', 'samsumg galaxy tablet', 'kindle fire', 'ipad air') THEN user_id ELSE NULL END) AS tablet
  FROM tutorial.yammer_events
  WHERE event_type = 'engagement'
  GROUP BY 1
  ORDER BY 1
  )
SELECT  week,
        mobile,
        mobile  - LAG(mobile, 1) OVER (ORDER BY week) AS usage
FROM table1


/*Engagement through mobile of top 5 countires by user base*/

SELECT  DATE_TRUNC('week', occurred_at),
        location,
        COUNT(DISTINCT CASE WHEN device IN ('amazon fire phone', 'nexus 10', 'iphone 5', 'nexus 7', 'iphone 5s', 'nexus 5', 'htc one',
                                            'iphone 4s','samsung galaxy note', 'nokia lumia 635', 'samsung galaxy s4') THEN user_id ELSE NULL END) AS mobile
FROM tutorial.yammer_events
WHERE location IN (
    SELECT  z.location
    FROM (
        SELECT  location,
                COUNT(user_id) AS users
        FROM tutorial.yammer_events
        WHERE event_type = 'engagement'
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 5
        ) z
        )
GROUP BY 1, 2


/*User's email data*/

SELECT  DATE_TRUNC('week', occurred_at),
        action,
        COUNT(DISTINCT user_id) AS total
FROM tutorial.yammer_emails
GROUP BY 1, 2
ORDER BY 1


/*email clickthrough rates*/

SELECT  week,
        weekly_opens / CASE WHEN weekly_emails = 0 THEN 1 ELSE weekly_emails END::float AS weekly_open_rate,
        weekly_ctr  / CASE WHEN weekly_opens = 0 THEN 1 ELSE weekly_opens END::float AS weekly_ctr,
        retain_opens / CASE WHEN retain_emails = 0 THEN 1 ELSE retain_emails END::float AS retain_open_rate,
        retain_ctr / CASE WHEN retain_opens = 0 THEN 1 ELSE retain_opens END::float AS retain_ctr
FROM (
  SELECT DATE_TRUNC('week',e1.occurred_at) AS week,
         COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e1.user_id ELSE NULL END) AS weekly_emails,
         COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e2.user_id ELSE NULL END) AS weekly_opens,
         COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e3.user_id ELSE NULL END) AS weekly_ctr,
         COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e1.user_id ELSE NULL END) AS retain_emails,
         COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e2.user_id ELSE NULL END) AS retain_opens,
         COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e3.user_id ELSE NULL END) AS retain_ctr
    FROM tutorial.yammer_emails e1
    LEFT JOIN tutorial.yammer_emails e2
      ON e2.occurred_at >= e1.occurred_at
     AND e2.occurred_at < e1.occurred_at + INTERVAL '5 MINUTE'
     AND e2.user_id = e1.user_id
     AND e2.action = 'email_open'
    LEFT JOIN tutorial.yammer_emails e3
      ON e3.occurred_at >= e2.occurred_at
     AND e3.occurred_at < e2.occurred_at + INTERVAL '5 MINUTE'
     AND e3.user_id = e2.user_id
     AND e3.action = 'email_clickthrough'
   WHERE e1.occurred_at >= '2014-06-01'
     AND e1.occurred_at < '2014-09-01'
     AND e1.action IN ('sent_weekly_digest','sent_reengagement_email')
   GROUP BY 1
   ) a
ORDER BY 1


/*% change in email clickthrough*/

/*
While visualizing this query we can create a
calculated field of SUM(email_ctr) / SUM(email_clickthrough) to create a percentage value.
*/

WITH table1 AS (
  SELECT  DATE_TRUNC('week', occurred_at) AS week,
          COUNT(DISTINCT CASE WHEN action  = 'email_clickthrough' THEN user_id ELSE NULL END) AS email_clickthrough
  FROM tutorial.yammer_emails
  GROUP BY 1
  ORDER BY 1
  )
SELECT  week,
        email_clickthrough,
        email_clickthrough - LAG(email_clickthrough, 1) OVER (ORDER BY week) AS email_ctr
FROM table1
