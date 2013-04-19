function ret = AchieveUserTagFriendByUserFriend(user_tag_friend,user_friend)

ret = zeros(size(user_tag_friend));

uf_count = size(user_friend,1);
index = 1;
for i = 1:uf_count
    temp_utf = user_tag_friend(user_tag_friend(:,1)==user_friend(i,1) & user_tag_friend(:,3)==user_friend(i,2),:);
    temp_utf_count = size(temp_utf,1);
    ret(index:index+temp_utf_count-1,:) = temp_utf;
    index = index + temp_utf_count;
end
ret(ret(:,1)==0,:) = [];
end