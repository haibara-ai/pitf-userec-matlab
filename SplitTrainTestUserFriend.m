function [train,test] = SplitTrainTestUserFriend(user_friend,fix)

%%
% Split user_tag_friend data by Leave-one strateroty
users = unique(user_friend(:,1));
user_count = length(users);
train = zeros(size(user_friend));
test = zeros(user_count,2);
index = 1;
for i = 1:user_count    
    friends = user_friend(user_friend(:,1) == users(i),2);
    friend_count = length(friends);
    if friend_count <= 1
        continue;
    end
    if fix ~= 0
        test(i,:) = [users(i) friends(1)];
        train(index:index+friend_count-2,:) = [users(i)*ones(1,friend_count-1);friends(2:end)']';
    else
        friends = friends(randperm(friend_count));
        test(i,:) = [users(i),friends(1)];
        train(index:index+friend_count-2,:) = [users(i)*ones(1,friend_count-1);friends(2:end,1)']';
    end
    index = index + friend_count;
end
test(test(:,1) == 0,:) = [];
train(train(:,1) == 0,:) = [];
end