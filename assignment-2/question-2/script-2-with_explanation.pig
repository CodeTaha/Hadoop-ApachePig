user_links = LOAD '/home/hduser/scalable_cloud/assignment-2/data/very-user-links-small.txt' USING PigStorage() as (userA:int, userB:int);


user_wall = LOAD '/home/hduser/scalable_cloud/assignment-2/data/very-user-wall-small.txt' USING PigStorage() as (userA:int, userB:int, ts:int);


# Getting all Distinct users in userA and userB in user_links

user_l_AA = FOREACH user_links GENERATE userA; 
user_l_A = DISTINCT user_l_AA;

user_l_BB = FOREACH user_links GENERATE userB; 
user_l_B = DISTINCT user_l_BB;

#merging in lists
temp_All_User_Links= UNION user_l_A, user_l_B;

# Final user_list from user_links sorting in ascending order

All_UsersInLinks = ORDER temp_All_User_Links By $0;

# Repeating the above steps for all users in user_wall

user_l_AA = FOREACH user_wall GENERATE userA; 
user_l_A = DISTINCT user_l_AA;
user_l_BB = FOREACH user_wall GENERATE userB; 
user_l_B = DISTINCT user_l_BB;
temp_All_User_wall= UNION user_l_A, user_l_B;
All_UsersInWall = ORDER temp_All_User_wall By $0;

# UNION  of All_UsersInLinks & All_UsersInWall

temp_All= UNION All_UsersInLinks,All_UsersInWall;
tAll_Users = DISTINCT temp_All;

# File containing All_Users
All_Users = ORDER tAll_Users By $0;

# STORING ALL_USERS
store All_Users into '/home/hduser/scalable_cloud/assignment-2/output/All_Users';

#Finding the node degree for each user

group_by_userA = group user_links by userA;

count_by_userA = FOREACH group_by_userA GENERATE group, COUNT(user_links);

# JOIN all users with their Node Degrees
JA = JOIN All_Users BY userA, count_by_userA by group;

#Filtering duplicate columns
ND_AU = FOREACH JA GENERATE $0,$2;

# STORING NodeDegree_All_Users
store ND_AU into '/home/hduser/scalable_cloud/assignment-2/output/ND_AU';

# NEXT StePS filter only the posts in particular time period, Group and count them according to user_id, Join with ND_AU, Group ND_AU according to Node degree Done!!

# selecting post between certain time period
walls_betw = FILTER user_wall by ts>1165506888 and ts<1230061119;

# group by userA
group_by_userA = group walls_betw by userA;

#Count wall posts according to UserA
count_by_userA = FOREACH group_by_userA GENERATE group, COUNT(walls_betw);

# STORING count_by_userA
store count_by_userA into '/home/hduser/scalable_cloud/assignment-2/output/count_by_userA';

# JOIN ND_AU with count_by_userA
JA = JOIN ND_AU BY userA, count_by_userA by group;

#Filtering duplicate columns
ND_AU_wall = FOREACH JA GENERATE $0,$1,$3;

# STORING ND_AU_wall {userA, ND, wall}
store ND_AU_wall into '/home/hduser/scalable_cloud/assignment-2/output/ND_AU_wall';


# Loading because of destruction
ND_AU_wall = LOAD '/home/hduser/scalable_cloud/assignment-2/output/ND_AU_wall/part-r-00000' USING PigStorage() as (userA:int, ND:int, WP:int);

#Group By node degree
Group_ND_AU_wall = GROUP ND_AU_wall by $1;

# Final output by counting 
final_op = FOREACH Group_ND_AU_wall GENERATE group, AVG(ND_AU_wall.$2);


