# Load user-links-small.txt
user_links = LOAD '/home/hduser/scalable_cloud/assignment-2/data/user-links-very-small.txt' USING PigStorage() as (userA:int, userB:int);

# Group by first user's friends
group_by_userA = group user_links by userA;

# count the friends of each user
count_by_userA = FOREACH group_by_userA GENERATE group, COUNT(user_links);

# group users with counts
group_by_count = GROUP count_by_userA by $1;

# count the number of bags in each degree
final_count = FOREACH group_by_count GENERATE group, COUNT(count_by_userA.$1);

# store the output
store final_count into '/home/hduser/scalable_cloud/assignment-2/question-1/output';

#user_links2 = LOAD '/home/hduser/scalable_cloud/assignment-2/data/user-links-small.txt' USING PigStorage() as (userA:int, userB:int);group_by_userA2 = group user_links2 by userA;count_by_userA2 = FOREACH group_by_userA2 GENERATE group, COUNT(user_links2);group_by_count2 = GROUP count_by_userA2 by $1;final_count2 = FOREACH group_by_count2 GENERATE group, COUNT(count_by_userA2.$1);



